import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
import * as admin from 'firebase-admin';
//import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createOpponent, createGame, createPlayer } from '../test_util/datacreation';
import { DateTime, Duration, Settings } from 'luxon';
import { clearFirestoreData } from '@firebase/rules-unit-testing';
import * as notifyforgame from '../../ts/util/notifyforgame';
import * as functions from 'firebase-functions';
import * as dl from '../../ts/util/dynamiclinks';
import { DataNodeCache } from '../../ts/util/datacache';
import chai, { expect, should } from 'chai';
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

import { onGameCreate } from '../../ts/db/game/notifyoncreate.f';

describe('Games Tests (create)', () => {
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

        const dynamicLinkStub = sinon.stub(dl, 'getShortLink');
        dynamicLinkStub.callsFake((subject: string, path: string) => {
            return new Promise((resolve, reject) => {
                resolve('http://bits.link/stuff/' + path);
            });
        });

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

    it('create game - too late', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now()
            .minus(Duration.fromObject({ minutes: 31 }))
            .toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.notCalled(spy);
        sinon.assert.notCalled(emailSpy);
        return;
    });

    it('create game - now', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'New Game vs {{opponent.name}}',
                body: 'New game arrive by {{arrivalTime}} for {{team.name}} ' + 'at {{placeName}}',
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
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.create.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.create.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] New {{sharedGame.type}} created for {{team.name}} at {{arrivalTime}}',
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

    it('create practice - now', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Practice');

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'New Practice for {{team.name}}',
                body: 'New practice arrive by {{arrivalTime}} at {{placeName}}',
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
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.create.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.create.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] New {{sharedGame.type}} created for {{team.name}} at {{arrivalTime}}',
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

    it('create event - now', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Event');

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.calledWith(
            spy,
            sinon.match.any,
            {
                title: 'New Event for {{team.name}}',
                body: 'New event {{game.name}} arrive by {{arrivalTime}} at {{placeName}}',
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
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.create.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.create.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] New {{sharedGame.type}} created for {{team.name}} at {{arrivalTime}}',
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

    it('create other - now', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id, undefined, 'Other');

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.notCalled(spy);
        sinon.assert.notCalled(emailSpy);
        return;
    });

    it('create game - no notification', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now()
            .plus(Duration.fromObject({ days: 3 }))
            .toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        await test.wrap(onGameCreate)(game, undefined);

        sinon.assert.notCalled(spy);

        // Check the email was called correctly.
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.create.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.create.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] New {{sharedGame.type}} created for {{team.name}} at {{arrivalTime}}',
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

    it('create game - with Win result', async () => {
        spy.reset();
        emailSpy.reset();
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now()
            .plus(Duration.fromObject({ days: 3 }))
            .toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);
        await game.ref.update({
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

        await test.wrap(onGameCreate)(await game.ref.get(), undefined);

        sinon.assert.notCalled(spy);

        // Check the email was called correctly.
        const payloadTxt = fs.readFileSync('lib/ts/templates/notify/game.create.txt', 'utf8');
        const payloadHtml = fs.readFileSync('lib/ts/templates/notify/game.create.html', 'utf8');
        emailSpy.should.have.been.callCount(1);
        sinon.assert.calledWith(
            emailSpy,
            sinon.match.any,
            {
                from: 'noreply@email.teamsfuse.com',
                text: payloadTxt,
                body: payloadHtml,
                title: '[{{team.name}}] New {{sharedGame.type}} created for {{team.name}} at {{arrivalTime}}',
                tag: 'email',
                click_action: 'openGame',
            },
            '',
            'emailOnUpdates',
            sinon.match.any,
            new notifyforgame.ChangedData(),
        );

        // And the results are updated.
        const updatedSeason = await teamAndSeason.season.ref.get();
        const updatedOpponent = await opponent.ref.get();
        const seasonData: { [field: string]: any } = {};
        seasonData[seasonDocId] = {
            win: 1,
            loss: 0,
            tie: 0,
        };
        expect(updatedOpponent.data()).to.be.deep.equal({
            teamUid: teamDocId,
            uid: opponent.id,
            name: 'fluff',
            seasons: seasonData,
        });
        expect(updatedSeason.data()).to.be.deep.equal({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamDocId,
            isPublic: true,
            users: {
                me: {
                    added: true,
                    admin: true,
                },
            },
            players: {
                player: {
                    me: true,
                    added: true,
                    public: false,
                    jerseyNumber: '42',
                    playerUid: 'player',
                    role: 'Player',
                },
            },
            record: {
                win: 1,
                tie: 0,
                loss: 0,
            },
        });

        return;
    });
});