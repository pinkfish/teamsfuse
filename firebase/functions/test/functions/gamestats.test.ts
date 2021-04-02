import sinon, { stubInterface } from 'ts-sinon';
import { firebaseTest } from '../test_util/firebase';
//import { expect } from 'chai';
import * as admin from 'firebase-admin';
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
        sinon.assert.calledWith(res.send, '<b>Unable to find player/season undefined</b>');
        sinon.assert.calledWith(res.status, 405);
    });

    it('no player', async () => {
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        try {
            req.method = 'POST';
            req.body = {
                playerUid: '1234',
                seasonUid: seasonDocId,
            };
            await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

            sinon.assert.calledWith(res.end as any);
            sinon.assert.calledWith(res.send, '<b>Unable to find player/season undefined</b>');
            sinon.assert.calledWith(res.status, 405);
        } finally {
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('no games', async () => {
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const player = await createPlayer(['me'], 'player');
        // Just make sure creating a club actually works.

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        try {
            req.method = 'POST';
            req.body = {
                playerUid: 'player',
                seasonUid: seasonDocId,
            };
            await gameStats((req as unknown) as Request, (res as unknown) as Response<any>);

            sinon.assert.calledWith(res.end as any);
            sinon.assert.calledWith(res.send, '<b>Unable to find player/season undefined</b>');
            sinon.assert.calledWith(res.status, 405);
        } finally {
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Players').doc(player.id).delete();
        }
    });

    it('no games - public', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const player = await createPlayer(['me'], 'player', true);
        // Just make sure creating a club actually works.

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        try {
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
        } finally {
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Players').doc(player.id).delete();
        }
    });
    it('one game - public', async () => {
        const teamAndSeason = await createSeasonAndTeam(true, true);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const player = await createPlayer(['me'], 'player', true);
        const opponent = await createOpponent(teamDocId, 'fluff');
        const arriveTime = DateTime.now().toUTC();
        const game = await createGame(teamDocId, seasonDocId, arriveTime, opponent.id);
        // Just make sure creating a club actually works.

        const req = stubInterface<Request>();
        const res = stubInterface<Response>();
        try {
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
                        result: {
                            result: 'Unknown',
                            inProgress: 'NotStarted',
                            currentPeriod: 'NotStarted--0',
                            divisions: 'Quarters',
                            scores: {},
                        },
                        playerSummary: undefined,
                        players: { player: {} },
                        sharedData: {
                            name: '',
                            time: arriveTime.valueOf(),
                            timezone: 'America/Los_Angeles',
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
        } finally {
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Players').doc(player.id).delete();
            await admin.firestore().collection('Games').doc(game.id).delete();
            //await admin.firestore().collection('GamesShared').doc(game.sharedDataUid).delete();
        }
    });
});
