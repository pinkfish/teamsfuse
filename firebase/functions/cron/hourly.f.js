'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const moment = require('moment-timezone');
const notifyforgame = require('../util/notifyforgame');

var db = admin.firestore();

// 2 hours.
const CUT_OFF_DURATION = moment.duration({ hours: 2 });
const LOOK_AHEAD_DURATION = moment.duration({ hours: 2 });

exports = module.exports =
    functions.pubsub.topic('hourly-tick').onPublish((data, context) => {
        // Do something useful every hour.
        const now = moment().add(LOOK_AHEAD_DURATION);
        const cutoff = moment().subtract(CUT_OFF_DURATION);
        return db.collection("Games")
            .where("arrivalTime", ">", cutoff.valueOf())
            .where("arrivalTime", "<", now.valueOf())
            .get()
            .then(snapshot => {
                var promiseSeasons = [snapshot.docs];
                for (var index in snapshot.docs) {
                    if (snapshot.docs.hasOwnProperty(index)) {
                        var doc = snapshot.docs[index];
                        console.log('Processing game ' + doc.id);
                        if (doc.data().notifiedHour) {
                            console.log('Already notified about ' + doc.id);
                            continue;
                        }
                        // Get the shared data for the game too.
                        var sharedGame = db.collection("GamesShared")
                                    .doc(doc.data().sharedDataUid)
                                    .get();
                        promiseSeasons.push(index);
                        promiseSeasons.push(sharedGame);
                    }
                }
                return Promise.all(promiseSeasons);
            }).then(results => {
                var games = results[0];
                var promiseSeasons = [games];
                for (var index in results) {
                    if (results.hasOwnProperty(index) && index > 1 && index % 2 === 0) {
                        var gameIndex = results[index];
                        var doc = games[gameIndex];
                        var sharedGame = results[index+1];
                        console.log('Games index ' + gameIndex + ' ' + index);
                        console.log(games);
                        console.log(results[index + 1]);

                        // Send notification to users, get all the players.
                        // Get all the players users.
                        // Send notifications.
                        var notification = {}
                        if (doc.data().type === 'EventType.Practice') {
                            notification = {
                                title: 'Practice for {{team.name}}',
                                body: 'Starting at {{arrivalTime}} to {{endTime}}',
                            }
                        } else if (doc.data().type === 'EventType.Game') {
                            notification = {
                                title: 'Game vs {{opponent.name}} for {{team.name}}',
                                body: 'Arrive by {{arrivalTime}}, game at {{gameTime}}',
                            }
                        } else if (doc.data().type === 'EventType.Event') {
                            notification = {
                                title: 'Event for {{team.name}}',
                                body: 'Arrive by {{arrivalTime}}',
                            }
                        }
                        var payload = {}
                        notification.body += ' for {{team.name}}';
                        notification.body += ' located {{game.place.address}}'
                        if (data.uniform !== '') {
                            notification.body += ' wear {{game.uniform}}';
                        }
                        payload['options'] = {
                            timeToLive: 1080,
                            collapseKey: doc.id
                        }
                        payload['data'] = {
                            ts: doc.arrivalTime,
                            body: notification.body,
                            title: notification.title,
                            k: doc.id,
                            a: sharedGame.data().place.address,
                            p: sharedGame.data().place.placeId,
                        }
                        notification['clickAction'] = 'GAME'
                        notification['tag'] = inputData.after.id
                        payload['notification'] = notification;

                        if (sharedGame.data().place !== null) {
                            payload['data'] = {
                                a: sharedGame.data().place.address,
                                p: sharedGame.data().place.placeId
                            }
                        }

                        if (payload) {
                            console.log(payload);
                            promiseSeasons.push(notifyforgame.notifyForGame(doc, payload, null));
                        }
                    }
                }
                return Promise.all(promiseSeasons);
            }).then(results => {
                var games = results[0];
                var allRets = [];
                for (gameId in games) {
                    if (games.hasOwnProperty(gameId)) {
                        game = games[gameId];
                        // Mark this as notified.
                        allRets.push(db.collection("Games").doc(game.id).update({notifiedHour: true}));
                    }
                }
                return Promise.all(allRets);
            })
    });