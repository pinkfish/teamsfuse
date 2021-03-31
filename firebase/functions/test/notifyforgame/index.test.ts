import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
//import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { createSeasonAndTeam, createGame, createOpponent } from '../util/datacreation';
//import * as functions from 'firebase-functions';
import { DateTime, Settings } from 'luxon';

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

import { notifyForGame } from '../../ts/util/notifyforgame';

describe('Notify for games - tests', () => {
    before(() => {
        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('notify', async () => {
        const spy = sinon.stub(admin.messaging(), 'sendToDevice');
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        console.log('Created season ' + seasonDocId);
        // Just make sure creating a club actually works.
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
            );
            sinon.assert.calledWith(spy, ['123'], {}, {});
        } finally {
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });
});
