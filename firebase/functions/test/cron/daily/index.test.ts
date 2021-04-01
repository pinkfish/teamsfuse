import * as sinon from 'sinon';
import { firebaseTest } from '../../test_util/firebase';
//import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { createSeasonAndTeam, createGame, createOpponent } from '../../test_util/datacreation';
import * as notifyforgame from '../../../ts/util/notifyforgame';
import * as functions from 'firebase-functions';
import { DateTime, Duration, Settings } from 'luxon';

const projectName = 'teamsfuse';

const test = firebaseTest(projectName);

test.mockConfig({
    mailgun: {
        apikey: 'frog',
        domain: 'frog.com',
    },
    links: {
        key: 'rabbit',
    },
    algolia: {
        appid: 'frog',
        key: 'rabbit',
    },
});

import { onDailyPublish, testExport } from '../../../ts/cron/daily.f';

describe('Cron tests - daily', () => {
    let spy: sinon.SinonStub<
        [
            game: functions.firestore.DocumentSnapshot,
            payload: notifyforgame.PayloadData,
            excludeUser: string,
            userFlag: string,
        ],
        Promise<void>
    >;
    let backupDb: sinon.SinonStub<[databaseName: string], Promise<void>>;

    before(() => {
        spy = sinon.stub(notifyforgame, 'emailForGame');
        backupDb = sinon.stub(testExport, 'doExport');
        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('no games', async () => {
        spy.resetHistory();
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        // Just make sure creating a club actually works.
        await test.wrap(onDailyPublish)(null, undefined);
        sinon.assert.calledWith(backupDb, 'projects/teamsfuse/databases/(default)');

        sinon.assert.notCalled(spy);
        await admin.firestore().collection('Teams').doc(teamDocId).delete();
        await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
    });

    it('one games to alert', async () => {
        spy.resetHistory();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        // Just make sure creating a club actually works.
        try {
            await test.wrap(onDailyPublish)(null, undefined);
            sinon.assert.calledWith(backupDb, 'projects/teamsfuse/databases/(default)');

            sinon.assert.calledWith(
                spy,
                sinon.match.any,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text:
                        '\n' +
                        'Reminder for upcoming game with {{team.name}}, details below:\n' +
                        '\n' +
                        'Arrive At   : {{arrivalTime}}\n' +
                        'Start Time  : {{startTime}}\n' +
                        'Address     : {{sharedGame.place.address}}\n' +
                        'PlaceName   : {{sharedGame.place.name}}\n' +
                        'PlaceNotes  : {{sharedGame.place.notes}}\n' +
                        'Uniform     : {{game.uniform}}\n' +
                        'Notes       : {{game.notes}}\n' +
                        '\n' +
                        'Availability\n' +
                        '{{textAvailability}}\n' +
                        '\n' +
                        'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                        '\n' +
                        'Map: {{directionsUrl}}\n' +
                        '\n' +
                        'http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}\n' +
                        '\n' +
                        '---\n' +
                        'Sent by TeamsFuse http://www.teamsfuse.com\n',
                    body:
                        '\n' +
                        'Reminder for upcoming game with <b>{{team.name}}</b>, details below:\n' +
                        '\n' +
                        '<img src="{{teamPhotoUrl}}" width=100 height=100>\n' +
                        '\n' +
                        '<h4><a href="http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}">Details</a></h4>\n' +
                        '<table>\n' +
                        '<tr>\n' +
                        '<td>Arrive At</td><td>{{arrivalTime}}</td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>Start Time</td><td>{{startTime}}</td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>Address     </td><td><a href="{{directionsUrl}}">{{sharedGame.place.address}}</a></td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>PlaceName   </td><td> {{sharedGame.place.name}}</td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>PlaceNotes  </td><td> {{sharedGame.place.notes}}</td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>Uniform     </td><td> {{game.uniform}}</td>\n' +
                        '</tr>\n' +
                        '<tr>\n' +
                        '<td>Notes       </td><td> {{game.notes}}</td>\n' +
                        '</tr>\n' +
                        '</table>\n' +
                        '\n' +
                        '<h4>Availability</h4>\n' +
                        '{{htmlAvailability}}\n' +
                        '\n' +
                        '<p>\n' +
                        'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                        '<p>\n' +
                        'Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>\n',
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
            );
        } finally {
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('multiple games to alert', async () => {
        spy.resetHistory();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDocs = [
            await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy'),
            await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy'),
            await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy'),
            await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy'),
        ];

        // Just make sure creating a club actually works.
        try {
            await test.wrap(onDailyPublish)(null, undefined);
            for (const idx in gameDocs) {
                console.log(idx);
                sinon.assert.calledWith(
                    spy,
                    sinon.match.any,
                    {
                        from: 'noreply@email.teamsfuse.com',
                        title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                        text:
                            '\n' +
                            'Reminder for upcoming game with {{team.name}}, details below:\n' +
                            '\n' +
                            'Arrive At   : {{arrivalTime}}\n' +
                            'Start Time  : {{startTime}}\n' +
                            'Address     : {{sharedGame.place.address}}\n' +
                            'PlaceName   : {{sharedGame.place.name}}\n' +
                            'PlaceNotes  : {{sharedGame.place.notes}}\n' +
                            'Uniform     : {{game.uniform}}\n' +
                            'Notes       : {{game.notes}}\n' +
                            '\n' +
                            'Availability\n' +
                            '{{textAvailability}}\n' +
                            '\n' +
                            'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                            '\n' +
                            'Map: {{directionsUrl}}\n' +
                            '\n' +
                            'http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}\n' +
                            '\n' +
                            '---\n' +
                            'Sent by TeamsFuse http://www.teamsfuse.com\n',
                        body:
                            '\n' +
                            'Reminder for upcoming game with <b>{{team.name}}</b>, details below:\n' +
                            '\n' +
                            '<img src="{{teamPhotoUrl}}" width=100 height=100>\n' +
                            '\n' +
                            '<h4><a href="http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}">Details</a></h4>\n' +
                            '<table>\n' +
                            '<tr>\n' +
                            '<td>Arrive At</td><td>{{arrivalTime}}</td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>Start Time</td><td>{{startTime}}</td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>Address     </td><td><a href="{{directionsUrl}}">{{sharedGame.place.address}}</a></td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>PlaceName   </td><td> {{sharedGame.place.name}}</td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>PlaceNotes  </td><td> {{sharedGame.place.notes}}</td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>Uniform     </td><td> {{game.uniform}}</td>\n' +
                            '</tr>\n' +
                            '<tr>\n' +
                            '<td>Notes       </td><td> {{game.notes}}</td>\n' +
                            '</tr>\n' +
                            '</table>\n' +
                            '\n' +
                            '<h4>Availability</h4>\n' +
                            '{{htmlAvailability}}\n' +
                            '\n' +
                            '<p>\n' +
                            'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                            '<p>\n' +
                            'Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>\n',
                        tag: 'email',
                        click_action: 'openGame',
                    },
                    '',
                    'emailUpcoming',
                );
            }
        } finally {
            for (const idx in gameDocs) {
                await admin.firestore().collection('Games').doc(gameDocs[idx].id).delete();
            }
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('games none to alert', async () => {
        spy.resetHistory();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(
            teamDocId,
            seasonDocId,
            DateTime.now()
                .toUTC()
                .minus(Duration.fromObject({ day: 2 })),
            opponent.id,
            'Froggy',
        );
        const gameDoc2 = await createGame(
            teamDocId,
            seasonDocId,
            DateTime.now()
                .toUTC()
                .plus(Duration.fromObject({ day: 6 })),
            opponent.id,
            'Froggy',
        );

        try {
            // Just make sure creating a club actually works.
            await test.wrap(onDailyPublish)(null, undefined);
            sinon.assert.notCalled(spy);
        } finally {
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Games').doc(gameDoc2.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });
});
