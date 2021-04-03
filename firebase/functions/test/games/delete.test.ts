import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
import * as admin from 'firebase-admin';
//import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createOpponent, createGame, createPlayer } from '../test_util/datacreation';
import { DateTime, Duration, Settings } from 'luxon';
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

import { onGameDelete } from '../../ts/db/game/notifyondelete.f';

describe('Games Tests (delete)', () => {
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

    it('delete game - too late', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now()
            .minus(Duration.fromObject({ minutes: 31 }))
            .toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameDelete)(game, undefined);

        sinon.assert.notCalled(spy);
        return;
    });

    it('delete game - now', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameDelete)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'CANCELLED Game vs {{opponent.name}}',
                body: 'Cancelled game at {{arrivalTime}} for {{team.name}} ' + 'located {{game.place.address}}',
                tag: `${game.id}change`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            {
                timeToLive: 10800000,
                collapseKey: `${game.id}change`,
            },
            '',
            false,
            sinon.match.any,
        );
        return;
    });

    it('delete practice - now', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Practice');

        await test.wrap(onGameDelete)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'CANCELLED Practice for {{team.name}}',
                body: 'Cancelled practice at {{arrivalTime}} located {{game.place.address}}',
                tag: `${game.id}change`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            {
                timeToLive: 10800000,
                collapseKey: `${game.id}change`,
            },
            '',
            false,
            sinon.match.any,
        );
        return;
    });

    it('delete event - now', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Event');

        await test.wrap(onGameDelete)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'CANCELLED Event for {{team.name}}',
                body: 'Cancelled event at {{arrivalTime}} located {{game.place.address}}',
                tag: `${game.id}change`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            {
                timeToLive: 10800000,
                collapseKey: `${game.id}change`,
            },
            '',
            false,
            sinon.match.any,
        );
        return;
    });

    it('delete other - now', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Other');

        await test.wrap(onGameDelete)(game, undefined);

        sinon.assert.notCalled(spy);
        return;
    });
});
