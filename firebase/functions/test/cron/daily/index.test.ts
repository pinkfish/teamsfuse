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

import { onDailyPublish } from '../../../ts/cron/daily.f';

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

    before(() => {
        spy = sinon.stub(notifyforgame, 'emailForGame');
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
            sinon.assert.calledWith(
                spy,
                sinon.match.any,
                {
                    ts: 1527249600000,
                    k: gameDoc.id,
                    a: '1502 west test drive',
                    p: undefined,
                    click_action: 'GAME',
                    tag: gameDoc.id,
                    title: '',
                    body: '',
                },
                '',
                '',
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
                sinon.assert.calledWith(
                    spy,
                    sinon.match.any,
                    {
                        ts: 1527249600000,
                        k: gameDocs[idx].id,
                        a: '1502 west test drive',
                        p: undefined,
                        click_action: 'GAME',
                        tag: gameDocs[idx].id,
                        title: '',
                        body: '',
                    },
                    '',
                    '',
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
                .plus(Duration.fromObject({ day: 2 })),
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
