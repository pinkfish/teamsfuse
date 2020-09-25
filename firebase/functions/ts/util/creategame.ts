import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

const db = admin.firestore();

export async function createGameFromShared(
    sharedGameDoc: functions.firestore.DocumentSnapshot,
    leagueTeamDoc: functions.firestore.DocumentSnapshot,
) {
    const leagueTeamDocData = leagueTeamDoc.data();
    if (leagueTeamDocData === null || leagueTeamDocData === undefined) {
        console.error('The league data doc is not valid');
        return;
    }
    const sharedGameDocData = sharedGameDoc.data();
    if (sharedGameDocData === null || sharedGameDocData === undefined) {
        console.error('The shared game data doc is not valid');
        return;
    }
    // Lookup the team details.
    const teamDoc = await db.collection('Teams').doc(leagueTeamDocData.teamUid).get();
    const teamDocData = teamDoc.data();
    if (teamDocData === null || teamDocData === undefined) {
        console.error('The team  doc is not valid');
        return;
    }

    const opponents = await db.collection('Teams').doc(leagueTeamDocData.teamUid).collection('Opponents').get();
    // Setup the arrival time based on the team details.
    const arrivalTime = sharedGameDocData.time - teamDocData.arrivalTime * 60 * 1000;
    let opponentLeagueUid = '';
    if (sharedGameDocData.officialResult.homeTeamUid === leagueTeamDoc.id) {
        opponentLeagueUid = sharedGameDocData.officialResult.awayTeamUid;
    } else {
        opponentLeagueUid = sharedGameDocData.officialResult.homeTeamUid;
    }
    // See if we need to create an opponent and connect this up.
    let opponentUid;
    let opponentNameUid;
    const compareName = leagueTeamDocData.name.trim().toLowerCase();
    if (opponents.docs.length === 0) {
        // Look at all the opponents and see what we can do.
        for (const idx in opponents.docs) {
            const doc = opponents.docs[idx];
            const docData = doc.data();
            if (docData === undefined || docData === null) {
                continue;
            }
            if (docData.leagueTeamUid === leagueTeamDoc.id) {
                // This is us.
                opponentUid = doc.id;
            }
            if (docData.name.trim().toLowerCase() === compareName) {
                opponentNameUid = doc.id;
            }
        }
    }
    if (opponentUid === null) {
        opponentUid = opponentNameUid;
    }
    if (opponentUid === null) {
        const dataBits: { [name: string]: any } = {};
        dataBits[leagueTeamDoc.id] = { added: true };
        const newOpponent = {
            name: leagueTeamDocData.name,
            contact: '',
            leagueTeamUid: dataBits,
        };
        const createdOpponent = await db
            .collection('Teams')
            .doc(leagueTeamDocData.teamUid)
            .collection('Opponents')
            .add(newOpponent);
        opponentUid = createdOpponent.id;
        const newGame = {
            notes: '',
            arrivalTime: arrivalTime,
            // Don't create an opponent by default, team members can setup the mapping if they want.
            opponentUid: opponentUid,
            leagueOpponentUid: opponentLeagueUid,
            result: {
                inProgress: 'GameInProgress.NotStarted',
                result: 'GameResult.Unknown',
            },
            seasonUid: leagueTeamDocData.seasonUid,
            seriesId: '',
            sharedDataUid: sharedGameDoc.id,
            teamUid: teamDoc.id,
            uniform: '',
            trackAttendance: teamDocData.trackAttendance,
        };

        await db.collection('Games').add(newGame);
    }
    return;
}

export async function createOpponentForShared(
    sharedGameUid: string,
    leagueTeamDoc: functions.firestore.DocumentSnapshot,
    teamDoc: functions.firestore.DocumentSnapshot,
    opponentTeamDoc: functions.firestore.DocumentSnapshot,
) {
    // Need to make opponents for the ones that don't exist.
    const snapshot = await db
        .collection('Teams')
        .doc(teamDoc.id)
        .collection('Opponents')
        .where('leagueTeamUid.' + leagueTeamDoc.id + '.added', '==', true)
        .get();

    // Go through the opponents and match based on the ones that match the case
    // insensitive name.
    if (snapshot.docs.length === 0) {
        // Look at all the opponents and try that way.
        const opponents = await db.collection('Teams').doc(teamDoc.id).collection('Opponents').get();

        const compareName = leagueTeamDoc.data.name.toLowerCase().trim();
        for (const idx in opponents.docs) {
            const doc = opponents.docs[idx];
            if (doc.data.name.toLowerCase().trim() === compareName) {
                // Found it!
                const index = 'leagueTeamUid.' + leagueTeamDoc.id + '.added';
                const newData: { [name: string]: any } = {};
                newData[index] = true;
                await db.collection('Teams').doc(teamDoc.id).collection('Opponents').doc(doc.id).update(newData);
                return;
            }
        }
        // Didn't find it, so make the opponent.
        const dataBits: { [name: string]: any } = {};
        dataBits[leagueTeamDoc.id] = { added: true };

        const newOpponentData = {
            contact: '',
            name: leagueTeamDoc.data.name,
            leagueTeamUid: dataBits,
        };

        await db.collection('Teams').doc(teamDoc.id).collection('Opponents').add(newOpponentData);
    }
}
