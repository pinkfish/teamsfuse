import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as handlebars from 'handlebars';
import * as moment from 'moment-timezone';
import { sendMail } from './mailgun';

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

// This notifies everyone following the game of the specific payload.
// The game here is a DocumentSnapshot from firebase.
// It returns a promise with the evaluation chain.
export async function notifyForGame(
    game: functions.firestore.DocumentSnapshot,
    payload: PayloadData,
    options: admin.messaging.MessagingOptions,
    excludeUser: string,
    onlyGames: boolean,
) {
    const gameData = game.data();
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    if (gameData === undefined || gameData === null) {
        console.error('Invalid game data ' + game.id);
        return;
    }
    const season = await db.collection('Seasons').doc(gameData.seasonUid).get();
    const seasonData = season.data();
    if (seasonData === null || seasonData === undefined) {
        console.error('Invalid game data, season missing [' + gameData.seasonUid + '] game ' + gameData.uid);
        return;
    }
    const teamRef = db.collection('Teams').doc(gameData.teamUid);
    const team = await teamRef.get();
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
        opponent = await teamRef.collection('Opponents').doc(gameData.opponentUid).get();
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
            const players = await db.collection('Players').doc(playerId).get();
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
                        const user = await db.collection('UserData').doc(userId).get();
                        await handleTokens(
                            user,
                            gameData,
                            teamData,
                            opponentData,
                            seasonData,
                            sharedGameData,
                            payload,
                            options,
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
) {
    if (user.exists) {
        const userData = user.data();
        if (userData === null || userData === undefined) {
            console.log('User Data not found');
            return;
        }

        // Setup the context and do the templates.
        const arrivalTime = moment.utc(gameData.arrivalTime).tz(sharedGameData.timezone).format('ddd MMM D LTS');
        const gameTime = moment.utc(sharedGameData.time).tz(sharedGameData.timezone).format('ddd MMM D LTS');
        const endTime = moment.utc(sharedGameData.endTime).tz(sharedGameData.timezone).format('ddd MMM D LTS');
        const context = {
            arrivalTime: arrivalTime,
            endTime: endTime,
            gameTime: gameTime,
            game: gameData,
            team: teamData,
            sharedGame: sharedGameData,
            opponent: opponentData,
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
                    console.log('Token cancelled ' + tokenKey);
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
                console.log('Removing ' + result.canonicalRegistrationToken);
                await db
                    .collection('UserData')
                    .doc(user.id)
                    .update('tokens.' + result.canonicalRegistrationToken, admin.firestore.FieldValue.delete());
            }
        }
    }

    return;
}

interface HtmlOrText {
    html: string;
    text: string;
}

function formatAvailability(input: string[], season: functions.firestore.DocumentSnapshot): HtmlOrText {
    let availabilityHtml = '';
    let availabilityText = '';
    let extraBitsHtml = '';
    let extraBitsText = '';
    const seasonData = season.data();
    if (seasonData === null || seasonData === undefined) {
        console.error('Invalid season ' + season.id);
        return {
            html: '',
            text: '',
        };
    }
    for (const playerUid in input) {
        if (Object.prototype.hasOwnProperty.call(seasonData.players, playerUid)) {
            const seasonPlayer = seasonData.players[playerUid];
            if (seasonPlayer.role === 'Player') {
                availabilityHtml += '<li>' + seasonPlayer.displayName;
                availabilityText += seasonPlayer.displayName;
                if (seasonPlayer.jerseyNumber !== null && seasonPlayer.jerseyNumber !== '') {
                    availabilityHtml += ' (#' + seasonPlayer.jerseyNumber + ')';
                    availabilityText += ' (#' + seasonPlayer.jerseyNumber + ')\n';
                }
            } else {
                extraBitsHtml += '<li>' + seasonPlayer.displayName;
                extraBitsText += seasonPlayer.displayName;
                if (seasonPlayer.role === 'Coach') {
                    extraBitsHtml += ' <b>(Coach)</b>';
                    extraBitsText += ' COACH\n';
                } else if (seasonPlayer.role === 'NonPlayer') {
                    extraBitsHtml += ' <b>(Non player</b>';
                    extraBitsText += ' NON PLAYER\n';
                }
            }
        }
    }

    return {
        html: availabilityHtml + extraBitsHtml,
        text: availabilityText + extraBitsText,
    };
}

export async function emailForGame(
    game: functions.firestore.DocumentSnapshot,
    payload: PayloadData,
    excludeUser: string,
    userFlag: string,
) {
    const gameData = game.data();
    if (gameData === null || gameData === undefined) {
        console.error('Invalid game data, game ' + game.id);
        return;
    }
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    const season = await db.collection('Seasons').doc(gameData.seasonUid).get();
    const teamRef = await db.collection('Teams').doc(gameData.teamUid);
    const team = await teamRef.get();
    const sharedGame = await db.collection('GamesShared').doc(gameData.sharedDataUid).get();

    const seasonData = season.data();
    if (seasonData === null || seasonData === undefined) {
        console.error('Invalid game data, season missing ' + season.id + ' game ' + game.id);
        return;
    }
    const teamData = team.data();
    if (teamData === null || teamData === undefined) {
        console.error('Invalid game data, season missing ' + team.id + ' game ' + game.id);
        return;
    }
    const sharedGameData = sharedGame.data();
    if (sharedGameData === null || sharedGameData === undefined) {
        console.error('Invalid game data, season missing ' + sharedGame.id + ' game ' + game.id);
        return;
    }

    payload.titleComp = handlebars.compile(payload.title);
    payload.textComp = handlebars.compile(payload.text);
    payload.bodyComp = handlebars.compile(payload.body);
    payload.fromComp = handlebars.compile(payload.from);

    let opponent: functions.firestore.DocumentSnapshot | null = null;
    if (gameData.opponentUid !== null && gameData.opponentUid !== '') {
        opponent = await teamRef.collection('Opponents').doc(gameData.opponentUid).get();
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
        if (Object.prototype.hasOwnProperty.call(seasonData.players, playerId)) {
            // Send the notification to this player.
            const players = await db.collection('Players').doc(playerId).get();
            if (players.exists) {
                const player = players.data();
                if (player === null || player === undefined) {
                    continue;
                }
                for (const userId in player.user) {
                    if (Object.prototype.hasOwnProperty.call(player.user, userId)) {
                        if (excludeUser !== userId) {
                            const user = await db.collection('UserData').doc(userId).get();
                            try {
                                await doTheNotification(
                                    user,
                                    game,
                                    team,
                                    opponent,
                                    season,
                                    sharedGame,
                                    payload,
                                    userFlag,
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
    user: functions.firestore.DocumentSnapshot,
    game: functions.firestore.DocumentSnapshot,
    team: functions.firestore.DocumentSnapshot,
    opponent: functions.firestore.DocumentSnapshot | null,
    season: functions.firestore.DocumentSnapshot,
    sharedGame: functions.firestore.DocumentSnapshot,
    payload: PayloadData,
    userFlag: string,
) {
    if (user.exists) {
        const gameData = game.data();
        if (gameData === null || gameData === undefined) {
            console.error('Shared game data is empty ' + game.id);
            return;
        }
        const seasonData = season.data();
        if (seasonData === null || seasonData === undefined) {
            console.error('Invalid game data, season missing ' + season.id + ' game ' + game.id);
            return;
        }
        const teamData = team.data();
        if (teamData === null || teamData === undefined) {
            console.error('Invalid game data, season missing ' + team.id + ' game ' + game.id);
            return;
        }
        const sharedGameData = sharedGame.data();
        if (sharedGameData === null || sharedGameData === undefined) {
            console.error('Invalid game data, season missing ' + sharedGame.id + ' game ' + game.id);
            return;
        }
        const userData = user.data();
        if (userData === null || userData === undefined) {
            console.error('Invalid user data ' + user.id);
            return;
        }
        if (userData.email && userData[userFlag]) {
            // Setup the context and do the templates.
            const arrivalTime = moment.utc(gameData.arrivalTime).tz(sharedGameData.timezone).format('ddd MMM D LTS');
            const gameTime = moment.utc(sharedGameData.time).tz(sharedGameData.timezone).format('ddd MMM D LTS');
            const endTime = moment.utc(sharedGameData.endTime).tz(sharedGameData.timezone).format('ddd MMM D LTS');
            let directionsUrl =
                'https://www.google.com/maps/dir/?api=1&destination=' +
                encodeURIComponent(sharedGameData.place.address);
            if (sharedGameData.place.placeId !== null) {
                directionsUrl += '&destination_place_id=' + encodeURIComponent(sharedGameData.place.placeId);
            }
            let availabilityHtml = '';
            let availabilityText = '';

            // Make the availability details.
            const yes = [];
            const no = [];
            const maybe = [];
            for (const playerUid in gameData.attendance) {
                if (Object.prototype.hasOwnProperty.call(gameData.attendance, playerUid)) {
                    const attend = gameData.attendance[playerUid];
                    if (attend['value'] === 'Attendence.Yes') {
                        yes.push(playerUid);
                    } else if (attend['value'] === 'Attendence.No') {
                        no.push(playerUid);
                    } else {
                        maybe.push(playerUid);
                    }
                }
            }

            let teamPhotoUrl: string;
            if (teamData.photoUrl !== null && teamData.photoUrl !== '') {
                teamPhotoUrl = teamData.photoUrl;
            } else {
                // Make it based on the sport.
                teamPhotoUrl = 'https://www.teamsfuse.com/assets/' + teamData.sport + '.png';
            }

            // Create a nice layout thingy.
            availabilityHtml = '<b>Yes</b><br><ul>';
            availabilityText = 'YES\n';
            let result = formatAvailability(yes, season);
            availabilityText += result.text;
            availabilityHtml += result.html;

            availabilityHtml += '<br><b>Maybe</b><br><ul>';
            availabilityText = '\nMAYBE\n';
            result = formatAvailability(no, season);
            availabilityText += result.text;
            availabilityHtml += result.html;

            availabilityHtml += '<br><b>No</b><br><ul>';
            availabilityText = '\nNO\n';
            result = formatAvailability(no, season);
            availabilityText += result.text;
            availabilityHtml += result.html;

            const opponentData = opponent ? opponent.data() : undefined;
            const context = {
                arrivalTime: arrivalTime,
                endTime: endTime,
                gameTime: gameTime,
                game: game.data(),
                team: team.data(),
                sharedGame: sharedGame.data(),
                opponent: opponentData,
                season: season.data(),
                directionsUrl: directionsUrl,
                availabilityHtml: availabilityHtml,
                availabilityText: availabilityText,
                teamPhotoUrl: teamPhotoUrl,
            };

            const sendPayload = {
                subject: payload.titleComp === undefined ? '' : payload.titleComp(context),
                text: payload.textComp === undefined ? '' : payload.textComp(context),
                html: payload.bodyComp === undefined ? '' : payload.bodyComp(context),
                from: payload.fromComp === undefined ? '' : payload.fromComp(context),
                to: userData.email,
            };
            try {
                await sendMail(sendPayload);
            } catch (error) {
                console.log('Error mailing ' + error);
            }
        }
    } else {
        console.log('No tokens for ' + user.id);
    }
}
