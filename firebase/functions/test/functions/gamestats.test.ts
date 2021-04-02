import sinon, { stubInterface } from 'ts-sinon';
import { firebaseTest } from '../test_util/firebase';
//import { expect } from 'chai';
import { createSeasonAndTeam, createPlayer, createOpponent, createGame } from '../test_util/datacreation';
import { Settings, DateTime } from 'luxon';
import { Request, Response } from 'express';
import { clearFirestoreData } from '@firebase/rules-unit-testing';

const projectName = 'teamsfuse';

firebaseTest(projectName);

import { gameStats } from '../../ts/functions/gamestats.f';

describe('functions - game stats', () => {
    before(() => {
        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        sinon.restore();
        return;
    });

    afterEach(async () => {
        await clearFirestoreData({
            projectId: projectName,
        });
    });

    it('get method', async () => {
        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'get';
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.send, '<b>Not a post message</b>');
        sinon.assert.calledWith(res.status, 405);
    });

    it('invalid args', async () => {
        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'POST';
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.send, '<b>Unable to find player/season undefined/undefined</b>');
        sinon.assert.calledWith(res.status, 405);
    });

    it('no player', async () => {
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const seasonDocId = teamAndSeason.season.id;

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'POST';
        req.body = {
            playerUid: '1234',
            seasonUid: seasonDocId,
        };
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.send, `<b>Unable to find player/season 1234/${seasonDocId}</b>`);
        sinon.assert.calledWith(res.status, 405);
    });

    it('no games', async () => {
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player');
        // Just make sure creating a club actually works.

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'POST';
        req.body = {
            playerUid: 'player',
            seasonUid: seasonDocId,
        };
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.send, `<b>Unable to find player/season player/${seasonDocId}</b>`);
        sinon.assert.calledWith(res.status, 405);
    });

    it('no games - public', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        // Just make sure creating a club actually works.

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'POST';
        req.body = {
            playerUid: 'player',
            seasonUid: seasonDocId,
        };
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.status, 200);
        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.json, {
            playerUid: 'player',
            seasonUid: seasonDocId,
            games: [],
        });
    });
    it('one game - public', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        req.method = 'POST';
        req.body = {
            playerUid: 'player',
            seasonUid: seasonDocId,
        };
        await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

        sinon.assert.calledWith(res.status, 200);
        sinon.assert.calledWith(res.end as any);
        sinon.assert.calledWith(res.json, {
            playerUid: 'player',
            seasonUid: seasonDocId,
            games: [
                {
                    uid: game.id,
                    arrivalTime: arriveTime.valueOf(),
                    seasonUid: seasonDocId,
                    teamUid: teamDocId,
                    result: {
                        result: 'Unknown',
                        inProgress: 'NotStarted',
                        currentPeriod: 'NotStarted--0',
                        divisions: 'Quarters',
                        scores: {},
                    },
                    playerSummary: undefined,
                    players: { player: {} },
                    uniform: '',
                    notes: '',
                    sharedDataUid: game.data()!.sharedData.uid,
                    sharedData: {
                        uid: game.data()!.sharedData.uid,
                        name: '',
                        time: arriveTime.valueOf(),
                        endTime: arriveTime.valueOf(),
                        timezone: 'America/Los_Angeles',
                        type: 'Game',
                        place: {
                            address: '1502 west test drive',
                            name: 'Test High School',
                            lat: 12,
                            long: 34,
                        },
                        officialResult: {
                            result: 'Unknown',
                            scores: {},
                        },
                    },
                },
            ],
        });
    });
});
