import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as handlebars from 'handlebars';
import * as fs from 'fs';

import { DateTime } from 'luxon';
import { sendMail } from './mailgun';
import { DataNodeCache } from './datacache';
import { getContentType, getImageFromUrl, Attachment } from './sendemail';
import { getShortLink } from './dynamiclinks';

const db = admin.firestore();

// Exposed for testing.
export const sendToDevice = {
    sendToDevice: (
        registrationToken: string | string[],
        payload: admin.messaging.MessagingPayload,
        options?: admin.messaging.MessagingOptions | undefined,
    ): Promise<admin.messaging.MessagingDevicesResponse> =>
        admin.messaging().sendToDevice(registrationToken, payload, options),
};

export interface PayloadNotification {
    title?: string;
    body?: string;
    icon?: string;
}

export interface PayloadData {
    from?: string;
    uniform?: string;
    text?: string;
    ts?: number;
    k?: string;
    p?: string;
    a?: string;
    title: string;
    body: string;
    tag: string;
    click_action: string;
    data?: {
        gameUid: string;
        action: string;
        click_action: string;
    };
    titleComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
    bodyComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
    subjectComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
    textComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
    htmlComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
    fromComp?: HandlebarsTemplateDelegate<{ [name: string]: any }>;
}

export class ChangedData {
    arrival: boolean = false;
    startTime: boolean = false;
    place: {
        name: boolean;
        address: boolean;
        notes: boolean;
    } = { name: false, address: false, notes: false };
    notes: boolean = false;
    uniform: boolean = false;
}

// This notifies everyone following the game of the specific payload.
// The game here is a DocumentSnapshot from firebase.
// It returns a promise with the evaluation chain.
export async function notifyForGame(
    game: functions.firestore.DocumentSnapshot,
    payload: PayloadData,
    options: admin.messaging.MessagingOptions,
    excludeUser: string,
    onlyGames: boolean,
    cache: DataNodeCache,
) {
    const gameData = game.data();
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    if (gameData === undefined || gameData === null) {
        console.error('Invalid game data ' + game.id);
        return;
    }
    const season = await cache.getSeason(gameData.seasonUid);
    const seasonData = season.data();
    if (seasonData === null || seasonData === undefined) {
        console.error('Invalid game data, season missing [' + gameData.seasonUid + '] game ' + gameData.uid);
        return;
    }
    const team = await cache.getTeam(gameData.teamUid);
    const teamData = team.data();
    if (teamData === null || teamData === undefined) {
        console.error('Invalid game data, team missing ' + gameData.teamUid + ' game ' + gameData.uid);
        return;
    }
    const sharedGameData = gameData.sharedData;
    if (sharedGameData === null || sharedGameData === undefined) {
        console.error('Invalid game data, shared game missing ' + gameData.sharedDataUid + ' game ' + gameData.uid);
        return;
    }

    let opponent: functions.firestore.DocumentSnapshot | null = null;
    let opponentData: { [field: string]: any } | undefined = undefined;
    if (payload.title) {
        payload.titleComp = handlebars.compile<{ [name: string]: any }>(payload.title);
        payload.bodyComp = handlebars.compile<{ [name: string]: any }>(payload.body);
    }
    if (gameData.opponentUid !== null && gameData.opponentUid !== '') {
        opponent = await cache.getOpponent(gameData.teamUid, gameData.opponentUid);
        opponentData = opponent.data();
    }

    // Put in all the default pieces.  This will mean we always open a game for these
    // notifications.
    payload['data'] = {
        gameUid: game.id,
        action: 'openGame',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    // If we already have a shared game, don't reload it.
    if (onlyGames) {
        if (sharedGameData.type !== 'Game') {
            console.log('Not a game');
            // Return an empty array.
            return [];
        }
    }
    // Now get the players.
    for (const playerId in seasonData.players) {
        if (Object.prototype.hasOwnProperty.call(seasonData.players, playerId)) {
            // Send the notification to this player.
            const players = await cache.getPlayer(playerId);
            if (!players.exists) {
                console.log('No player ' + playerId);
                continue;
            }
            const player = players.data();
            if (player === null || player === undefined) {
                console.error('Cannot find player ' + playerId);
                continue;
            }
            for (const userId in player.users) {
                if (Object.prototype.hasOwnProperty.call(player.users, userId)) {
                    if (excludeUser !== userId) {
                        const user = await cache.getUser(userId);
                        await handleTokens(
                            user,
                            gameData,
                            teamData,
                            opponentData,
                            seasonData,
                            sharedGameData,
                            payload,
                            options,
                            cache,
                        );
                    } else {
                        console.log('Excluding ' + userId);
                    }
                }
            }
        }
    }
    return;
}

async function handleTokens(
    user: functions.firestore.DocumentSnapshot,
    gameData: { [field: string]: any },
    teamData: { [field: string]: any },
    opponentData: { [field: string]: any } | undefined,
    seasonData: { [field: string]: any },
    sharedGameData: { [field: string]: any },
    payload: PayloadData,
    options: admin.messaging.MessagingOptions,
    cache: DataNodeCache,
) {
    if (user.exists) {
        const userData = user.data();
        if (userData === null || userData === undefined) {
            console.log('User Data not found');
            return;
        }

        // Setup the context and do the templates.
        const arrivalTime = DateTime.fromMillis(gameData.arrivalTime).setZone(sharedGameData.timezone).toFormat('ffff');
        const gameTime = DateTime.fromMillis(sharedGameData.time).setZone(sharedGameData.timezone).toFormat('ffff');
        const endTime = DateTime.fromMillis(sharedGameData.endTime).setZone(sharedGameData.timezone).toFormat('ffff');
        const context = {
            arrivalTime: arrivalTime,
            endTime: endTime,
            gameTime: gameTime,
            game: gameData,
            team: teamData,
            sharedGame: sharedGameData,
            opponent: opponentData,
            placeName: gameData.sharedData.place.name ?? gameData.sharedData.place.address,
            season: seasonData,
        };

        const sendMessage: admin.messaging.MessagingPayload = {
            notification: {
                body: payload.bodyComp ? payload.bodyComp(context) : '',
                title: payload.titleComp ? payload.titleComp(context) : '',
                icon: 'https://teamsfuse.firebaseapp.com/assets/sports/' + teamData.sport + '.png',
                tag: payload.tag,
                clickAction: payload.click_action,
            },
            data: { ...payload.data },
        };

        if (sendMessage.notification === null || sendMessage.notification === undefined) {
            console.error('No notification section');
            return;
        }

        if (sendMessage['data'] === null || sendMessage['data'] === undefined) {
            sendMessage['data'] = {
                gameUid: gameData.Uid,
                action: 'openGame',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else {
            sendMessage['data']['gameUid'] = gameData.uid;
            sendMessage['data']['click_action'] = 'FLUTTER_NOTIFICATION_CLICK';
        }

        const newTokens = [];
        for (const tokenKey in userData.tokens) {
            if (userData.tokens.hasOwnProperty(tokenKey)) {
                if (tokenKey) {
                    newTokens.push(tokenKey);
                } else {
                    await db
                        .collection('UserData')
                        .doc(user.id)
                        .update('tokens.' + tokenKey, admin.firestore.FieldValue.delete());
                }
            }
        }
        if (newTokens.length > 0) {
            const mess: admin.messaging.MessagingPayload = {
                ...sendMessage,
            };

            const response = await sendToDevice.sendToDevice(newTokens, mess, options);
            await handleNotifyResponse(user, response);
        }
    } else {
        console.log('No user ' + user.id);
    }

    return;
}

async function handleNotifyResponse(
    user: functions.firestore.DocumentSnapshot,
    response: admin.messaging.MessagingDevicesResponse,
) {
    // If we have a results property then it was for sending stuff.
    for (const idx in response.results) {
        const result = response.results[idx];
        const error = result.error;
        if (error) {
            console.error('Failure sending notification to', user.id, error);
            // Cleanup the tokens that are not registered anymore.
            if (
                error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered'
            ) {
                await db
                    .collection('UserData')
                    .doc(user.id)
                    .update('tokens.' + result.canonicalRegistrationToken, admin.firestore.FieldValue.delete());
            }
        }
    }

    return;
}

interface NameAndRole {
    name: string;
    role: string;
}

async function formatAvailability(input: Set<string>, seasonData: { [field: string]: any }): Promise<NameAndRole[]> {
    const roles: NameAndRole[] = [];

    for (const playerUid of input) {
        const seasonPlayer = seasonData.players[playerUid];
        // Get the player from the database.seasonData
        const player = await db.collection('Players').doc(playerUid).get();
        const playerData = player.data();
        let playerName = 'unknown';
        if (playerData !== null && playerData !== undefined) {
            playerName = playerData.name;
        }
        if (seasonPlayer.role === 'Player') {
            if (seasonPlayer.jerseyNumber !== null && seasonPlayer.jerseyNumber !== '') {
                playerName += ' (#' + seasonPlayer.jerseyNumber + ')';
            }
            roles.push({ name: playerName, role: '' });
        } else {
            if (seasonPlayer.role === 'Coach') {
                roles.push({ name: playerName, role: 'Coach' });
            } else if (seasonPlayer.role === 'NonPlayer') {
                roles.push({ name: playerName, role: 'Non Player' });
            } else {
                roles.push({ name: playerName, role: 'Unknown' });
            }
        }
    }

    roles.sort((a, b) => a.name.localeCompare(b.name));

    return roles;
}

export async function emailForGame(
    game: functions.firestore.DocumentSnapshot,
    payload: PayloadData,
    excludeUser: string,
    userFlag: string,
    cache: DataNodeCache,
    changedData: ChangedData,
) {
    const gameData = game.data();
    if (gameData === null || gameData === undefined) {
        console.error('Invalid game data, game ' + game.id);
        return;
    }
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    const season = await cache.getSeason(gameData.seasonUid);
    const team = await cache.getTeam(gameData.teamUid);

    const seasonData = season.data();
    if (seasonData === null || seasonData === undefined) {
        console.error('Invalid game data, season missing ' + season.id + ' game ' + game.id);
        return;
    }
    const teamData = team.data();
    if (teamData === null || teamData === undefined) {
        console.error('Invalid game data, team missing ' + team.id + ' game ' + game.id);
        return;
    }
    const sharedGameData = gameData.sharedData;
    if (sharedGameData === null || sharedGameData === undefined) {
        console.error('Invalid game data, shared data ' + gameData.sharedDataUid + ' game ' + game.id);
        return;
    }

    payload.titleComp = handlebars.compile(payload.title);
    payload.textComp = handlebars.compile(payload.text);
    payload.bodyComp = handlebars.compile(payload.body);
    payload.fromComp = handlebars.compile(payload.from);

    handlebars.registerHelper('changedText', function (check) {
        if (check) {
            return ' [changed]';
        }
        return '';
    });

    handlebars.registerHelper('changed', function (check, options) {
        const ret = options.fn(options.data.root);
        if (check) {
            return new handlebars.SafeString('<b>' + ret + ' <i>[changed]</i></b>');
        }
        return new handlebars.SafeString(ret);
    });

    let opponentData: { [field: string]: any } | undefined = undefined;
    if (gameData.opponentUid !== null && gameData.opponentUid !== '') {
        const opponent = await cache.getOpponent(gameData.teamUid, gameData.opponentUid);
        opponentData = opponent.data();
    }

    // Put in all the default pieces.  This will mean we always open a game for these
    // notifications.
    payload['data'] = {
        gameUid: game.id,
        action: 'openGame',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    // Now get the players.
    for (const playerId in seasonData.players) {
        if (seasonData.players.hasOwnProperty(playerId)) {
            // Send the notification to this player.
            const players = await cache.getPlayer(playerId);
            if (players.exists) {
                const player = players.data();
                if (player === null || player === undefined) {
                    continue;
                }
                for (const userId in player.users) {
                    if (player.users.hasOwnProperty(userId)) {
                        if (excludeUser !== userId) {
                            const user = await cache.getUser(userId);
                            const userData = user.data();
                            if (userData === null || userData === undefined) {
                                console.error('Invalid user data,  ' + userId + ' game ' + game.id);
                                continue;
                            }
                            try {
                                await doTheNotification(
                                    userData,
                                    gameData,
                                    teamData,
                                    opponentData,
                                    seasonData,
                                    sharedGameData,
                                    payload,
                                    userFlag,
                                    changedData,
                                );
                            } catch (error) {
                                console.error('There was an error while sending the notification:', error);
                            }
                        } else {
                            console.log('Excluding ' + userId);
                        }
                    }
                }
            }
        }
    }
}

async function doTheNotification(
    userData: { [field: string]: any },
    gameData: { [field: string]: any },
    teamData: { [field: string]: any },
    opponentData: { [field: string]: any } | undefined,
    seasonData: { [field: string]: any },
    sharedGameData: { [field: string]: any },
    payload: PayloadData,
    userFlag: string,
    changedData: ChangedData,
) {
    if (userData.email && userData[userFlag]) {
        // Setup the context and do the templates.
        const arrivalTime = DateTime.fromMillis(gameData.arrivalTime).setZone(sharedGameData.timezone).toFormat('ffff');
        const gameTime = DateTime.fromMillis(sharedGameData.time).setZone(sharedGameData.timezone).toFormat('ffff');
        const endTime = DateTime.fromMillis(sharedGameData.endTime).setZone(sharedGameData.timezone).toFormat('ffff');
        let directionsUrl =
            'https://www.google.com/maps/dir/?api=1&destination=' + encodeURIComponent(sharedGameData.place.address);
        if (sharedGameData.place.placeId !== null) {
            directionsUrl += '&destination_place_id=' + encodeURIComponent(sharedGameData.place.placeId);
        }

        // Make the availability details.
        const yes = new Set<string>();
        const no = new Set<string>();
        const maybe = new Set<string>();
        for (const playerUid in gameData.attendance) {
            if (gameData.attendance.hasOwnProperty(playerUid)) {
                const attend = gameData.attendance[playerUid];
                if (attend === 'Yes') {
                    yes.add(playerUid);
                } else if (attend === 'No') {
                    no.add(playerUid);
                } else {
                    maybe.add(playerUid);
                }
            }
        }
        // Update all the ones not in the list as maybe.
        for (const playerUid in seasonData.players) {
            if (seasonData.players.hasOwnProperty(playerUid)) {
                if (!yes.has(playerUid) && !no.has(playerUid)) {
                    maybe.add(playerUid);
                }
            }
        }

        let teamPhotoUrl: string;
        if (teamData.photoUrl && teamData.photoUrl !== '') {
            teamPhotoUrl = teamData.photoUrl;
        } else {
            // Make it based on the sport.
            teamPhotoUrl = 'https://www.teamsfuse.com/assets/' + teamData.sport + '.png';
        }

        // Create a nice layout thingy.
        const availability = {
            yes: await formatAvailability(yes, seasonData),
            no: await formatAvailability(no, seasonData),
            maybe: await formatAvailability(maybe, seasonData),
        };

        const gameUrl = await getShortLink(
            'Game for ' + teamData.name,
            '/Game/View/' + seasonData.uid + '/' + gameData.uid,
        );
        const teamUrl = await getShortLink(teamData.name, '/Team/View/' + teamData.uid);
        const context = {
            arrivalTime: arrivalTime,
            endTime: endTime,
            gameTime: gameTime,
            game: gameData,
            team: teamData,
            sharedGame: sharedGameData,
            opponent: opponentData,
            season: seasonData,
            directionsUrl: directionsUrl,
            availability: availability,
            teamPhotoUrl: 'cid:teamimg',
            change: changedData,
            gameUrl: gameUrl,
            teamUrl: teamUrl,
        };

        const footerTxt = handlebars.compile(fs.readFileSync('lib/ts/templates/footer.txt', 'utf8'));
        const footerHtml = handlebars.compile(fs.readFileSync('lib/ts/templates/footer.html', 'utf8'));
        let attachments: Attachment[];
        try {
            const image = await getImageFromUrl(teamPhotoUrl);
            attachments = [
                {
                    filename: 'apple-store-badge.png',
                    path: 'lib/ts/templates/img/apple-store-badge.png',
                    cid: 'apple-store',
                },
                {
                    filename: 'google-store-badge.png',
                    path: 'lib/ts/templates/img/google-play-badge.png',
                    cid: 'google-store',
                },
                {
                    filename: 'team.jpg',
                    content: Buffer.from(image.data).toString('base64'),
                    cid: 'teamimg',
                    contentType: getContentType(image),
                    encoding: 'base64',
                },
            ];
        } catch (e) {
            // No team image...
            attachments = [
                {
                    filename: 'apple-store-badge.png',
                    path: 'lib/ts/templates/img/apple-store-badge.png',
                    cid: 'apple-store',
                },
                {
                    filename: 'google-store-badge.png',
                    path: 'lib/ts/templates/img/google-play-badge.png',
                    cid: 'google-store',
                },
            ];
        }

        const sendPayload = {
            subject: payload.titleComp === undefined ? '' : payload.titleComp(context),
            text: (payload.textComp === undefined ? '' : payload.textComp(context)) + footerTxt(context),
            html: (payload.bodyComp === undefined ? '' : payload.bodyComp(context)) + footerHtml(context),
            from: payload.fromComp === undefined ? '' : payload.fromComp(context),
            to: userData.email,
            attachments: attachments,
        };
        try {
            await sendMail(sendPayload);
        } catch (error) {
            console.log('Error mailing ' + error);
        }
    }
}
