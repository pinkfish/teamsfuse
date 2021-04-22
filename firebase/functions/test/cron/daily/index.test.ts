import * as sinon from 'sinon';
import { firebaseTest } from '../../test_util/firebase';
//import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { createSeasonAndTeam, createGame, createOpponent } from '../../test_util/datacreation';
import * as notifyforgame from '../../../ts/util/notifyforgame';
import * as functions from 'firebase-functions';
import { DateTime, Duration, Settings } from 'luxon';
import * as email from '../../../ts/util/email';
import { DataNodeCache } from '../../../ts/util/datacache';
import { clearFirestoreData } from '@firebase/rules-unit-testing';

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
            cache: DataNodeCache,
            changed: notifyforgame.ChangedData,
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

    afterEach(async () => {
        await clearFirestoreData({
            projectId: projectName,
        });
    });

    it('no games', async () => {
        spy.resetHistory();
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        // Just make sure creating a club actually works.
        await test.wrap(onDailyPublish)(undefined);
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
        await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        // Just make sure creating a club actually works.
        await test.wrap(onDailyPublish)(undefined);
        sinon.assert.calledWith(backupDb, 'projects/teamsfuse/databases/(default)');

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                text: email.TEXT_BODY,
                body: email.HTML_BODY,
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailUpcoming',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );
    });

    it('one games to alert - only sent once', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        // Just make sure creating a club actually works.
        await test.wrap(onDailyPublish)(undefined);
        sinon.assert.calledWith(backupDb, 'projects/teamsfuse/databases/(default)');

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                text: email.TEXT_BODY,
                body: email.HTML_BODY,
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailUpcoming',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );

        // Update and now check again.
        spy.reset();
        await test.wrap(onDailyPublish)(undefined);
        sinon.assert.calledWith(backupDb, 'projects/teamsfuse/databases/(default)');

        sinon.assert.notCalled(spy);
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
        await test.wrap(onDailyPublish)(undefined);
        for (const _idx in gameDocs) {
            // eslint-disable-line no-unused-vars
            sinon.assert.calledWith(
                spy,
                sinon.match.any,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                sinon.match.any,
                new notifyforgame.ChangedData(),
            );
        }
    });

    it('games none to alert', async () => {
        spy.resetHistory();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        await createGame(
            teamDocId,
            seasonDocId,
            DateTime.now()
                .toUTC()
                .minus(Duration.fromObject({ day: 2 })),
            opponent.id,
            'Froggy',
        );
        await createGame(
            teamDocId,
            seasonDocId,
            DateTime.now()
                .toUTC()
                .plus(Duration.fromObject({ day: 6 })),
            opponent.id,
            'Froggy',
        );

        // Just make sure creating a club actually works.
        await test.wrap(onDailyPublish)(undefined);
        sinon.assert.notCalled(spy);
    });
});
