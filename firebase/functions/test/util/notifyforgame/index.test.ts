import * as sinon from 'sinon';
import { firebaseTest } from '../../test_util/firebase';
import { expect } from 'chai';
import * as admin from 'firebase-admin';
import {
    createSeasonAndTeam,
    createGame,
    createOpponent,
    createPlayer,
    createUser,
} from '../../test_util/datacreation';
import { DateTime, Settings } from 'luxon';
import { DataNodeCache } from '../../../ts/util/datacache';

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

import { notifyForGame, sendToDevice } from '../../../ts/util/notifyforgame';

describe('Notify for games - tests', () => {
    let spy: sinon.SinonStub<
        [
            registrationToken: string | string[],
            payload: admin.messaging.MessagingPayload,
            options?: admin.messaging.MessagingOptions | undefined,
        ],
        Promise<admin.messaging.MessagingDevicesResponse>
    >;
    before(() => {
        spy = sinon.stub(sendToDevice, 'sendToDevice');

        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('notify - no user', async () => {
        spy.reset();
        spy.returns(
            new Promise<admin.messaging.MessagingDevicesResponse>(function (resolve, reject) {
                resolve({
                    failureCount: 0,
                    results: [
                        {
                            canonicalRegistrationToken: 'frog',
                            messageId: 'id',
                        },
                    ],
                    canonicalRegistrationTokenCount: 1,
                    multicastId: 1234,
                    successCount: 1,
                });
            }),
        );

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await notifyForGame(
                gameDoc,
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
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
                '',
                false,
                cache,
            );
            sinon.assert.notCalled(spy);
        } finally {
            cache.close();
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('notify - no tokens', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        await createPlayer(['me', 'other'], 'player');
        await createUser([], 'me');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await notifyForGame(
                gameDoc,
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
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
                '',
                false,
                cache,
            );
            sinon.assert.notCalled(spy);
        } finally {
            cache.close();
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('notify - works', async () => {
        spy.reset();
        spy.returns(
            new Promise<admin.messaging.MessagingDevicesResponse>(function (resolve, reject) {
                resolve({
                    failureCount: 0,
                    results: [
                        {
                            canonicalRegistrationToken: 'frog',
                            messageId: 'id',
                        },
                    ],
                    canonicalRegistrationTokenCount: 1,
                    multicastId: 1234,
                    successCount: 1,
                });
            }),
        );

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        const playerDoc = await createPlayer(['me', 'other'], 'player');
        const userDoc = await createUser(['1234'], 'me');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await notifyForGame(
                gameDoc,
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
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
                '',
                false,
                cache,
            );
            sinon.assert.calledWith(
                spy,
                ['1234'],
                {
                    notification: {
                        body: '',
                        title: '',
                        icon: 'https://teamsfuse.firebaseapp.com/assets/sports/undefined.png',
                        tag: gameDoc.id,
                        clickAction: 'GAME',
                    },
                    data: {
                        gameUid: gameDoc.id,
                        action: 'openGame',
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                },
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
            );
        } finally {
            cache.close();
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('UserData').doc(userDoc.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc.id).delete();
        }
    });

    it('notify - invalid token', async () => {
        spy.reset();
        spy.returns(
            new Promise<admin.messaging.MessagingDevicesResponse>(function (resolve, reject) {
                resolve({
                    failureCount: 0,
                    results: [
                        {
                            canonicalRegistrationToken: '1234',
                            messageId: 'id',
                            error: {
                                code: 'messaging/invalid-registration-token',
                                toJSON: () => {
                                    return { bing: '1234' };
                                },
                                message: 'bad token, bad token',
                            },
                        },
                    ],
                    canonicalRegistrationTokenCount: 1,
                    multicastId: 1234,
                    successCount: 1,
                });
            }),
        );

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        const playerOoc = await createPlayer(['me', 'other'], 'player');
        const userDoc = await createUser(['1234'], 'me');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await notifyForGame(
                gameDoc,
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
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
                '',
                false,
                cache,
            );
            const updatedUserDoc = await admin.firestore().collection('UserData').doc(userDoc.id).get();
            expect(updatedUserDoc.data()!.tokens).to.deep.equal({});
            sinon.assert.calledWith(
                spy,
                ['1234'],
                {
                    notification: {
                        body: '',
                        title: '',
                        icon: 'https://teamsfuse.firebaseapp.com/assets/sports/undefined.png',
                        tag: gameDoc.id,
                        clickAction: 'GAME',
                    },
                    data: {
                        gameUid: gameDoc.id,
                        action: 'openGame',
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    },
                },
                {
                    timeToLive: 7200,
                    collapseKey: gameDoc.id,
                    title: 'Game vs {{opponent.name}} for {{team.name}}',
                    body:
                        'Arrive by {{arrivalTime}}, game at {{gameTime}} for {{team.name}} located {{game.place.address}} wear {{game.uniform}}',
                },
            );
        } finally {
            cache.close();
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('UserData').doc(userDoc.id).delete();
            await admin.firestore().collection('Players').doc(playerOoc.id).delete();
        }
    });
});
