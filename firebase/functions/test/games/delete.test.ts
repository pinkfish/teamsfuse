import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
//import * as admin from 'firebase-admin';
//import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createOpponent, createGame, createPlayer } from '../test_util/datacreation';
import { DateTime, Settings } from 'luxon';
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

import { onGameDelete } from '../../ts/db/game/notifyondelete.f';

describe('Games Tests', () => {
    before(() => {
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

    it('delete game - no message', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameDelete)(game, undefined);
        return;
    });
});
