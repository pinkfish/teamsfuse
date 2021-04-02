import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// db to write the feedback too.
const db = admin.firestore();

// Figure out the game stats.
export const gameStats = functions.https.onRequest(async (req, res) => {
    if (req.method === 'POST') {
        console.log(req.body);
        console.log(req.body['playerUid']);
        console.log(req.body.playerUid);
        const playerUid = req.body.playerUid;
        const seasonUid = req.body.seasonUid;
        let handled = false;
        const retGames: Record<string, any>[] = [];
        console.log(`Got ${playerUid}  ${seasonUid} ` + playerUid + ' -- ' + seasonUid);
        if (playerUid !== undefined && seasonUid !== undefined) {
            const seasonDoc = await db.collection('Seasons').doc(seasonUid).get();
            const seasonData = seasonDoc.data();
            console.log(`Season ${seasonDoc.exists}`);
            if (seasonData !== null && seasonData !== undefined) {
                const playerDoc = await db.collection('Players').doc(playerUid).get();
                const playerData = playerDoc.data();
                console.log(`Player ${playerDoc.exists}`);
                if (playerData !== null && playerData !== undefined) {
                    // Only for public players.
                    console.log(`Player ${playerData.isPublic} ${seasonData.isPublic}`);
                    if (playerData.isPublic && seasonData.isPublic) {
                        handled = true;
                        // Get the games and then the stats by player.
                        const games = await db.collection('Games').where('seasonUid', '==', seasonUid).get();
                        for (const doc of games.docs) {
                            const docData = doc.data();
                            if (docData !== null && docData !== undefined) {
                                let playerSummary: Record<string, any>;
                                if (
                                    docData.players !== undefined &&
                                    docData.players !== null &&
                                    docData.players.hasOwnProperty(playerUid)
                                ) {
                                    playerSummary = docData.players[playerUid] ?? {};
                                } else {
                                    playerSummary = {};
                                }
                                const details: Record<string, any> = {};
                                details[playerUid] = playerSummary;
                                retGames.push({
                                    uid: docData.uid,
                                    arrivalTime: docData.arrivalTime,
                                    seasonUid: docData.seasonUid,
                                    result: docData.result,
                                    playerSummary: docData.playerSummary,
                                    players: details,
                                    sharedData: {
                                        name: '',
                                        time: docData.sharedData.time,
                                        timezone: docData.sharedData.timezone,
                                        place: docData.sharedData.place,
                                        officialResult: docData.sharedData.officialResult,
                                    },
                                });
                            }
                        }
                    }
                }
            }
        }
        if (handled) {
            res.status(200);
            res.json({
                playerUid: playerUid,
                seasonUid: seasonUid,
                games: retGames,
            });
        } else {
            res.status(405);
            res.send(`<b>Unable to find player/season ${playerUid}/${seasonUid}</b>`);
        }
        res.end();
    } else {
        res.send('<b>Not a post message</b>');
        // Return a "method not allowed" error
        res.status(405);
        res.end();
    }
    return;
});

export default gameStats;
