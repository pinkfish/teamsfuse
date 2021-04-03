import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
import * as admin from 'firebase-admin';
//import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createOpponent, createGame, createPlayer } from '../test_util/datacreation';
import { DateTime, Settings } from 'luxon';
import { clearFirestoreData } from '@firebase/rules-unit-testing';
import * as notifyforgame from '../../ts/util/notifyforgame';
import * as functions from 'firebase-functions';
import { DataNodeCache } from '../../ts/util/datacache';

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

import { onGameUpdate } from '../../ts/db/game/notifyonupdate.f';

describe('Games Tests (update)', () => {
    let spy: sinon.SinonStub<
        [
            game: functions.firestore.DocumentSnapshot,
            payload: notifyforgame.PayloadData,
            options: admin.messaging.MessagingOptions,
            excludeUser: string,
            onlyGames: boolean,
            cache: DataNodeCache,
        ],
        Promise<never[] | undefined>
    >;

    before(() => {
        spy = sinon.stub(notifyforgame, 'notifyForGame');

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

    it('update game - no change', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameUpdate)(test.makeChange(game, game), undefined);

        sinon.assert.notCalled(spy);
        return;
    });
});
