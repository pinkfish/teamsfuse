'use strict';

const admin = require('firebase-admin');
const moment = require('moment-timezone');
const handlebars = require('handlebars');

const db = admin.firestore();

// This notifies everyone following the game of the specific payload.
// The game here is a DocumentSnapshot from firebase.
// It returns a promise with the evaluation chain.
exports.notifyForGame = (game, payload, excludeUser, onlyGames, sharedGameData) => {
    console.log('Processing game ' + game.id);
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    const seasonRef = db
        .collection('Seasons')
        .doc(game.data().seasonUid)
        .get();
    const teamRef = db.collection('Teams').doc(game.data().teamUid);
    const sharedGameRef = db.collection('GamesShared').doc(game.data().sharedDataUid);

    let opponent = null;
    if (payload.notification && payload.notification.title) {
        payload.notification.title = handlebars.compile(payload.notification.title);
        payload.notification.body = handlebars.compile(payload.notification.body);
    }
    if (game.data().opponentUid !== null && game.data().opponentUid !== '') {
        opponent = teamRef
            .collection('Opponents')
            .doc(game.data().opponentUid)
            .get();
    }

    // Put in all the default pieces.  This will mean we always open a game for these
    // notifications.
    payload['data'] = {
        gameUid: game.id,
        action: 'openGame',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    // If we already have a shared game, don't reload it.
    const sharedGame = sharedGameData === null ? sharedGameRef.get() : sharedGameData;

    return Promise.all([teamRef.get(), opponent, seasonRef, sharedGame])
        .then(data => {
            const team = data[0];
            const opponent = data[1];
            const season = data[2];
            const sharedGame = data[3];
            const promises = [];

            if (onlyGames) {
                if (sharedGame.data().type !== 'EventType.Game') {
                    console.log('Not a game');
                    // Return an empty array.
                    return [];
                }
            }
            console.log('Checking season ' + season.id);
            // Now get the players.
            const seasonData = season.data();
            for (const playerId in seasonData.players) {
                if (Object.prototype.hasOwnProperty.call(seasonData.players, playerId)) {
                    // Send the notification to this player.
                    const players = db
                        .collection('Players')
                        .doc(playerId)
                        .get();
                    promises.push(Promise.all([[game, team, opponent, season, sharedGame], players]));
                    console.log('Found player  ' + playerId);
                }
            }
            return Promise.all(promises);
        })
        .then(allPlayers => {
            const inner = [];
            // Now we have the player, this links to all the users.
            for (const key in allPlayers) {
                const extra = allPlayers[key][0];
                const snapshot = allPlayers[key][1];
                if (!snapshot.exists) {
                    console.log('No player ' + snapshot.id);
                    continue;
                }
                const player = snapshot.data();
                for (const userId in player.user) {
                    if (Object.prototype.hasOwnProperty.call(player.user, userId)) {
                        const excludeUser = extra[5];
                        if (excludeUser !== userId) {
                            const tokens = db
                                .collection('UserData')
                                .doc(userId)
                                .get();
                            inner.push(Promise.all([extra, tokens]));
                            console.log('Tokens for  ' + userId);
                        } else {
                            console.log('Excluding ' + userId);
                        }
                    }
                }
            }
            return Promise.all(inner);
        })
        .then(allTokens => {
            const allRets = [];

            for (const key in allTokens) {
                if (Object.prototype.hasOwnProperty.call(allTokens, key)) {
                    const extra = allTokens[key][0];
                    const tokens = allTokens[key][1];
                    if (tokens.exists) {
                        console.log('Processing user ' + tokens.id);
                        const game = extra[0];
                        const team = extra[1];
                        let opponent = extra[2];
                        const season = extra[3];
                        const sharedGame = extra[4];

                        // Setup the context and do the templates.
                        const arrivalTime = moment(game.data().arrivalTime)
                            .tz(sharedGame.data().timezone)
                            .format('ddd MMM D LTS');
                        const gameTime = moment(sharedGame.data().time)
                            .tz(sharedGame.data().timezone)
                            .format('ddd MMM D LTS');
                        const endTime = moment(sharedGame.data().endTime)
                            .tz(sharedGame.data().timezone)
                            .format('ddd MMM D LTS');
                        console.log(
                            'Game ' +
                                game.id +
                                ' ' +
                                arrivalTime +
                                ' ' +
                                gameTime +
                                ' ' +
                                endTime +
                                ' ' +
                                sharedGame.data().timezone,
                        );
                        console.log(
                            'Game ' +
                                game.id +
                                ' ' +
                                game.data().arrivalTime +
                                ' ' +
                                sharedGame.data().time +
                                ' ' +
                                sharedGame.data().endTime,
                        );
                        if (opponent) {
                            opponent = opponent.data();
                        }
                        const context = {
                            arrivalTime: arrivalTime,
                            endTime: endTime,
                            gameTime: gameTime,
                            game: game.data(),
                            team: team.data(),
                            sharedGame: sharedGame.data(),
                            opponent: opponent,
                            season: season.data(),
                        };
                        console.log(payload.notification);
                        const sendPayload = {
                            notification: {},
                        };

                        sendPayload['notification'] = Object.assign({}, payload['notification']);
                        const options = Object.assign({}, payload['options']);
                        sendPayload['notification']['icon'] =
                            'https://teamsfuse.firebaseapp.com/assets/sports/' + team.data().sport + '.png';
                        sendPayload['data'] = payload['data'];
                        if (sendPayload['data'] === null) {
                            sendPayload['data'] = {
                                gameUid: game.id,
                            };
                        } else {
                            sendPayload['data']['gameUid'] = game.id;
                        }
                        sendPayload['data']['click_action'] = 'FLUTTER_NOTIFICATION_CLICK';

                        if (sendPayload.notification) {
                            if (sendPayload.notification.title) {
                                sendPayload.notification.title = sendPayload.notification.title(context);
                                sendPayload.notification.body = sendPayload.notification.body(context);
                            }
                        }

                        console.log(sendPayload);
                        const newTokens = [];
                        for (const tokenKey in tokens.data().tokens) {
                            if (Object.prototype.hasOwnProperty.call(tokens.data().tokens, tokenKey)) {
                                const myData = tokens.data().tokens[tokenKey];
                                if (myData) {
                                    newTokens.push(tokenKey);
                                } else {
                                    console.log('Token cancelled ' + tokenKey);
                                    allRets.push(
                                        Promise.all([
                                            newTokens,
                                            db
                                                .collection('UserData')
                                                .doc(tokens.id)
                                                .update('tokens.' + tokenKey, admin.firestore.FieldValue.delete()),
                                        ]),
                                    );
                                }
                            }
                        }
                        if (newTokens.length > 0) {
                            console.log('Sending to tokens');
                            console.log(newTokens);
                            allRets.push(admin.messaging().sendToDevice(newTokens, sendPayload, options));
                        }
                    } else {
                        console.log('No tokens for ' + tokens.id);
                    }
                }
            }

            return Promise.all(allRets);
        })
        .then(response => {
            return handleNotifyResponse(response, tokenKey);
        })
        .catch(error => console.error('There was an error while sending the notification:', error));
};

function handleNotifyResponse(resppnse) {
    const tokensToRemove = [];
    for (const val in response) {
        if (typeof val === 'object' && val.constructor === Array) {
            var userOb = val[0];
            const pushResponse = val[1];
            // If we have a results property then it was for sending stuff.
            for (const idx in pushResponse.results) {
                const result = pushResponse[idx];
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to', userOb.id, error);
                    // Cleanup the tokens who are not registered anymore.
                    if (
                        error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered'
                    ) {
                        console.log('Removing ' + result.canonicalRegistrationToken);
                        tokensToRemove.push(
                            db
                                .collection('UserData')
                                .doc(userOb.id)
                                .update('tokens.' + userOb, admin.firestore.FieldValue.delete()),
                        );
                    }
                }
            }
        }
    }
    return Promise.all(tokensToRemove);
}

function formatAvailability(input, season) {
    let availabilityHtml = '';
    let availabilityText = '';
    let extraBitsHtml = '';
    let extraBitsText = '';
    for (const playerUid in input) {
        if (Object.prototype.hasOwnProperty.call(season.players, playerUid)) {
            const seasonPlayer = season.players[playerUid];
            if (seasonPlayer.role === 'RoleInTeam.Player') {
                availabilityHtml += '<li>' + seasonPlayer.displayName;
                availabilityText += seasonPlayer.displayName;
                if (seasonPlayer.jerseyNumber !== null && seasonPlayer.jerseyNumber !== '') {
                    availabilityHtml += ' (#' + seasonPlayer.jerseyNumber + ')';
                    availabilityText += ' (#' + seasonPlayer.jerseyNumber + ')\n';
                }
            } else {
                extraBitsHtml += '<li>' + seasonPlayer.displayName;
                extraBitsTex += seasonPlayer.displayName;
                if (seasonPlayer.role === 'RoleInTeam.Coach') {
                    extraBitsHtml += ' <b>(Coach)</b>';
                    extraBitsText += ' COACH\n';
                } else if (seasonPlayer.role === 'RoleInTeam.NonPlayer') {
                    extraBitsHtml += ' <b>(Non player</b>';
                    extraBitsText += ' NON PLAYER\n';
                }
            }
        }
    }

    return {
        availabilityHtml: availabilityHtml + extraBitsHtml,
        availabilityText: availabilityText + extraBitsText,
    };
}

exports.emailForGame = (game, payload, excludeUser, userFlag) => {
    console.log('Processing game ' + game.id);
    // Send notification to users, get all the players.
    // Get all the players users.
    // Send notifications.
    const seasonRef = db
        .collection('Seasons')
        .doc(game.data().seasonUid)
        .get();
    const teamRef = db.collection('Teams').doc(game.data().teamUid);
    const sharedGameRef = db
        .collection('GamesShared')
        .doc(game.data().sharedDataUid)
        .get();

    payload.subject = handlebars.compile(payload.subject);
    payload.text = handlebars.compile(payload.text);
    payload.html = handlebars.compile(payload.html);
    payload.from = handlebars.compile(payload.from);

    let opponent = null;
    if (game.data().opponentUid !== null && game.data().opponentUid !== '') {
        opponent = teamRef
            .collection('Opponents')
            .doc(game.data().opponentUid)
            .get();
    }

    // Put in all the default pieces.  This will mean we always open a game for these
    // notifications.
    payload['data'] = {
        gameUid: game.id,
        action: 'openGame',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
    };

    return Promise.all([teamRef.get(), opponent, seasonRef, sharedGameRef])
        .then(data => {
            const team = data[0];
            const opponent = data[1];
            const season = data[2];
            const sharedGame = data[3];
            const promises = [];
            console.log('Checking season ' + season.id);
            // Now get the players.
            const seasonData = season.data();
            for (const playerId in seasonData.players) {
                if (Object.prototype.hasOwnProperty.call(seasonData.players, playerId)) {
                    // Send the notification to this player.
                    const players = db
                        .collection('Players')
                        .doc(playerId)
                        .get();
                    promises.push(Promise.all([[game, team, opponent, season, sharedGame], players]));
                    console.log('Found player  ' + playerId);
                }
            }
            return Promise.all(promises);
        })
        .then(allPlayers => {
            const inner = [];
            // Now we have the player, this links to all the users.
            for (const key in allPlayers) {
                const extra = allPlayers[key][0];
                const snapshot = allPlayers[key][1];
                if (!snapshot.exists) {
                    console.log('No player ' + snapshot.id);
                    continue;
                }
                const player = snapshot.data();
                for (const userId in player.user) {
                    if (Object.prototype.hasOwnProperty.call(player.user, userId)) {
                        const excludeUser = extra[5];
                        if (excludeUser !== userId) {
                            const userData = db
                                .collection('UserData')
                                .doc(userId)
                                .get();
                            inner.push(Promise.all([extra, userData]));
                            console.log('UserData for  ' + userId);
                        } else {
                            console.log('Excluding ' + userId);
                        }
                    }
                }
            }
            return Promise.all(inner);
        })
        .then(allUsers => {
            const allRets = [];

            for (const key in allUsers) {
                if (Object.prototype.hasOwnProperty.call(allUsers, key)) {
                    const extra = allUsers[key][0];
                    const userData = allUsers[key][1];
                    if (userData.exists) {
                        console.log('Processing user ' + userData.id + ' ' + userFlag);
                        console.log(userData);
                        if (userData.email && userData[userFlag]) {
                            const game = extra[0];
                            const team = extra[1];
                            let opponent = extra[2];
                            const season = extra[3];
                            const sharedGame = extra[4];

                            // Setup the context and do the templates.
                            const arrivalTime = moment(game.data().arrivalTime)
                                .tz(sharedGame.data().timezone)
                                .format('ddd MMM D LTS');
                            const gameTime = moment(sharedGame.data().time)
                                .tz(sharedGame.data().timezone)
                                .format('ddd MMM D LTS');
                            const endTime = moment(sharedGame.data().endTime)
                                .tz(sharedGame.data().timezone)
                                .format('ddd MMM D LTS');
                            let directionsUrl =
                                'https://www.google.com/maps/dir/?api=1&destination=' +
                                encodeUriComponent(sharedGame.place.address);
                            if (sharedGame.place.placeId !== null) {
                                directionsUrl +=
                                    '&destination_place_id=' + encodeUriComponent(sharedGame.place.placeId);
                            }
                            let availabilityHtml = '';
                            let availabilityText = '';

                            // Make the availability details.
                            const yes = [];
                            const no = [];
                            const maybe = [];
                            for (const playerUid in game.attendance) {
                                if (Object.prototype.hasOwnProperty.call(game.attendance, playerUid)) {
                                    const attend = game.attendance[playerUid];
                                    if (attend['value'] === 'Attendence.Yes') {
                                        yes.push(playerUid);
                                    } else if (attend['value'] === 'Attendence.No') {
                                        no.push(playerUid);
                                    } else {
                                        maybe.push(playerUid);
                                    }
                                }
                            }

                            var teamPhotoUrl;
                            if (team.photoUrl !== null && team.photoUrl !== '') {
                                teamPhotoUrl = team.photoUrl;
                            } else {
                                // Make it based on the sport.
                                teamPhotoUrl = 'https://www.teamsfuse.com/assets/' + team.sport + '.png';
                            }

                            // Create a nice layout thingy.
                            availabilityHtml = '<b>Yes</b><br><ul>';
                            availabilityText = 'YES\n';
                            let result = formatAvailability(yes, season);
                            availabilityText += result.availabilityText;
                            availabilityHtml += result.availabilityHtml;

                            availabilityHtml += '<br><b>Maybe</b><br><ul>';
                            availabilityText = '\nMAYBE\n';
                            result = formatAvailability(no, season);
                            availabilityText += result.availabilityText;
                            availabilityHtml += result.availabilityHtml;

                            availabilityHtml += '<br><b>No</b><br><ul>';
                            availabilityText = '\nNO\n';
                            result = formatAvailability(no, season);
                            availabilityText += result.availabilityText;
                            availabilityHtml += result.availabilityHtml;

                            console.log(
                                'Game ' +
                                    game.id +
                                    ' ' +
                                    arrivalTime +
                                    ' ' +
                                    gameTime +
                                    ' ' +
                                    endTime +
                                    ' ' +
                                    game.data().timezone,
                            );
                            console.log(
                                'Game ' +
                                    game.id +
                                    ' ' +
                                    game.data().arrivalTime +
                                    ' ' +
                                    sharedGame.data().time +
                                    ' ' +
                                    sharedGame.data().endTime,
                            );
                            if (opponent) {
                                opponent = opponent.data();
                            }
                            const context = {
                                arrivalTime: arrivalTime,
                                endTime: endTime,
                                gameTime: gameTime,
                                game: game.data(),
                                team: team.data(),
                                sharedGame: sharedGame.data(),
                                opponent: opponent,
                                season: season.data(),
                                directionsUrl: directionsUrl,
                                availabilityHtml: availabilityHtml,
                                availabilityText: availabilityText,
                                teamPhotoUrl: teamPhotoUrl,
                            };

                            const sendPayload = {
                                subject: payload.subject(context),
                                text: payload.text(context),
                                html: payload.html(context),
                                from: payload.from(context),
                                to: userData.email,
                            };
                            console.log(sendPayload);
                            console.log('Emailing to user  ' + key + ' ' + userData.email);
                            allRets.push(mailTransport.sendMail(sendPayload));
                        }
                    } else {
                        console.log('No tokens for ' + tokens.id);
                    }
                }
            }

            return Promise.all(allRets);
        })
        .catch(error => console.error('There was an error while sending the notification:', error));
};
