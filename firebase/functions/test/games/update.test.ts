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
import chai, { should } from 'chai';
import SinonChai from 'sinon-chai';
import * as fs from 'fs';

// Setup chai and sinon.
chai.use(SinonChai);
should();

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

    let emailSpy: sinon.SinonStub<
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

    before(() => {
        spy = sinon.stub(notifyforgame, 'notifyForGame');

        emailSpy = sinon.stub(notifyforgame, 'emailForGame');

        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    beforeEach(() => {
        spy.reset();
        emailSpy.reset();
    });

    afterEach(async () => {
        await clearFirestoreData({
            projectId: projectName,
        });
    });

    it('update game - no change', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameUpdate)(test.makeChange(game, game), undefined);

        sinon.assert.notCalled(spy);
        sinon.assert.notCalled(emailSpy);
        return;
    });

    it('update game - change arrival', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);
        const oldData = game.data();
        oldData!['arrivalTime'] = 1234;
        const oldGame = {
            id: game.id,
            data: () => oldData,
        };

        await test.wrap(onGameUpdate)(test.makeChange(oldGame, game), undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'Game change vs {{opponent.name}}',
                body: 'Arrive by {{arrivalTime}} at {{placeName}}',
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

        // Check the email was called correctly.
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.updated.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.updated.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] Updated {{sharedGame.type}} for {{team.name}} at {{arrivalTime}}',
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailOnUpdates',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );

        return;
    });

    it('update practice - change arrival', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, 'frog', 'Practice');
        const oldData = game.data();
        oldData!['arrivalTime'] = 1234;
        const oldGame = {
            id: game.id,
            data: () => oldData,
        };

        await test.wrap(onGameUpdate)(test.makeChange(oldGame, game), undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'Practice change for {{team.name}}',
                body: 'Arrive by {{arrivalTime}} at {{placeName}}',
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

        // Check the email was called correctly.
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.updated.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.updated.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] Updated {{sharedGame.type}} for {{team.name}} at {{arrivalTime}}',
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailOnUpdates',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );

        return;
    });

    it('update event - change arrival', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, 'froggy', 'Event');
        const oldData = game.data();
        oldData!['arrivalTime'] = 1234;
        const oldGame = {
            id: game.id,
            data: () => oldData,
        };

        await test.wrap(onGameUpdate)(test.makeChange(oldGame, game), undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'Event change for {{team.name}}',
                body: '{{game.name}} arrive by {{arrivalTime}} at {{placeName}}',
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

        // Check the email was called correctly.
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.updated.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.updated.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] Updated {{sharedGame.type}} for {{team.name}} at {{arrivalTime}}',
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailOnUpdates',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );

        return;
    });

    it('update game - final result', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const oldGame = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, 'froggy', 'Game');
        await oldGame.ref.update({
            'result.result': 'Win',
            'result.inProgress': 'Final',
            'result.scores.Final': {
                period: 'Final',
                score: {
                    ptsFor: 20,
                    ptsAgainst: 12,
                },
            },
        });
        const game = await oldGame.ref.get();

        await test.wrap(onGameUpdate)(test.makeChange(oldGame, game), {
            auth: {
                uid: '1234',
            },
        });

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: '{{opponent.name}} 20 - 12',
                body: 'Won the game',
                click_action: 'GAMERESULT',
                tag: `${game.id}result`,
            },
            {
                timeToLive: 259200,
                collapseKey: `${game.id}result`,
            },
            '1234',
            true,
            sinon.match.any,
        );

        emailSpy.should.have.been.callCount(0);

        return;
    });
});
