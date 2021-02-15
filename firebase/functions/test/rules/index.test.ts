import * as firebase from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import { expect } from 'chai';

/*
 * ============
 *    Setup
 * ============
 */
const projectName = 'test-teamsfuse';
const coverageUrl = `http://localhost:9090/emulator/v1/projects/${projectName}:ruleCoverage.html`;

export type AppOptions = {
    databaseName?: string;
    projectId?: string;
    uid?: string;
    email_verified?: boolean;
};

/**
 * Creates a new app with authentication data matching the input.
 *
 * @param {object} auth the object to use for authentication (typically {uid: some-uid})
 * @return {object} the app.
 */
function authedApp(auth?: AppOptions) {
    return firebase.initializeTestApp({ projectId: projectName, auth }).firestore();
}

/*
 * ============
 *  Test Cases
 * ============
 */
beforeEach(async function () {
    // Clear the database between tests
    await firebase.clearFirestoreData({
        projectId: projectName,
    });
});

before(async function () {
    console.log('start before');
    console.log(fs.readFileSync('../firestore.rules', 'utf8'));
    console.log(projectName);
    await firebase.loadFirestoreRules({
        projectId: projectName,
        rules: fs.readFileSync('../firestore.rules', 'utf8'),
    });
    console.log('end before');
});

after(async function () {
    await Promise.all(firebase.apps().map((app) => app.delete()));
    console.log(`View rule coverage information at ${coverageUrl}\n`);
});

describe('TeamsFuse rules', function () {
    it('require users to log in before listing teams', async function () {
        const db = authedApp();
        await firebase.assertFails(db.collection('Teams').where('uid', '==', true).get());
    });
    it('require users to log in before listing clubs', async function () {
        const db = authedApp();
        await firebase.assertFails(db.collection('Clubs').where('uid', '==', true).get());
    });
    it('require users to log in before listing games', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('Games').where('uid', '==', true).get());
    });
    it('require users to log in before listing games shared', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('GamesShared').where('uid', '==', true).get());
    });
    it('require users to log in before listing invites', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('Invites').where('uid', '==', true).get());
    });
    it('everyone can list league', async () => {
        const db = authedApp();
        await firebase.assertSucceeds(db.collection('League').where('uid', '==', true).get());
    });
    it('everyone can list league divison', async () => {
        const db = authedApp();
        await firebase.assertSucceeds(db.collection('LeagueDivision').where('uid', '==', true).get());
    });
    it('everyone can list league season', async () => {
        const db = authedApp();
        await firebase.assertSucceeds(db.collection('LeagueSeason').where('uid', '==', true).get());
    });
    it('everyone can list league team', async () => {
        const db = authedApp();
        await firebase.assertSucceeds(db.collection('LeagueTeam').where('uid', '==', true).get());
    });
    it('require users to log in before listing message recipients', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('MessageRecipients').where('uid', '==', true).get());
    });
    it('require users to log in before listing messages', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('Messages').where('uid', '==', true).get());
    });
    it('get message', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await db
            .collection('Messages')
            .doc('frog')
            .set({
                fromUid: 'alice',
                timeSent: firebase.firestore.FieldValue.serverTimestamp(),
                recipients: { robert: { added: true } },
            });
        await db.collection('MessageRecipients').doc('frog').set({ fromUid: 'alice', messageId: 'frog' });
        await firebase.assertSucceeds(db.collection('Messages').doc('frog').get());
        const dbRobert = authedApp({ uid: 'robert' });
        await firebase.assertFails(dbRobert.collection('Messages').doc('frog').get());
    });
    it('require users to log in before listing players', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('Players').where('uid', '==', true).get());
    });
    it('require users to log in before listing seasons', async () => {
        const db = authedApp();
        await firebase.assertFails(db.collection('Seasons').where('uid', '==', true).get());
    });

    it('get team', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await db
            .collection('Teams')
            .doc('frog')
            .set({ admins: { alice: { added: true } } });
        await firebase.assertSucceeds(db.collection('Teams').doc('frog').get());
        const dbRobert = authedApp({ uid: 'robert' });
        await firebase.assertFails(dbRobert.collection('Teams').doc('frog').get());
    });
    it('get public team', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await db
            .collection('Teams')
            .doc('frogpublic')
            .set({
                admins: { alice: { added: true } },
                isPublic: true,
                players: { fluff: { added: true } },
                teamUid: 'team',
            });
        await firebase.assertSucceeds(db.collection('Teams').doc('frogpublic').get());
        const dbRobert = authedApp({ uid: 'robert' });
        await firebase.assertSucceeds(dbRobert.collection('Teams').doc('frogpublic').get());
        const dbAnon = authedApp();
        await firebase.assertSucceeds(dbAnon.collection('Teams').doc('frogpublic').get());
    });
    it('get season', async () => {
        const db = authedApp({ uid: 'robert', email_verified: true });
        await db
            .collection('Teams')
            .doc('team')
            .set({
                admins: {
                    robert: true,
                },
            });
        await db
            .collection('Seasons')
            .doc('frog')
            .set({ users: { robert: { added: true } }, players: { fluff: { added: true } }, teamUid: 'team' });
        await firebase.assertSucceeds(db.collection('Seasons').doc('frog').get());
        const aliceDb = authedApp({ uid: 'alice' });
        await firebase.assertFails(aliceDb.collection('Seasons').doc('frog').get());
    });
    it('get public season', async () => {
        const db = authedApp({ uid: 'robert', email_verified: true });
        await db
            .collection('Teams')
            .doc('team')
            .set({
                admins: {
                    robert: true,
                },
            });
        await db
            .collection('Seasons')
            .doc('frogpublic')
            .set({
                users: { robert: { added: true } },
                isPublic: true,
                players: { fluff: { added: true } },
                teamUid: 'team',
            });
        await firebase.assertSucceeds(db.collection('Seasons').doc('frogpublic').get());
        const aliceDb = authedApp({ uid: 'alice' });
        await firebase.assertSucceeds(aliceDb.collection('Seasons').doc('frogpublic').get());
        const dbAnon = authedApp();
        await firebase.assertSucceeds(dbAnon.collection('Seasons').doc('frogpublic').get());
    });
    it('get public club', async () => {
        const db = authedApp({ uid: 'robert', email_verified: true });
        await db
            .collection('Teams')
            .doc('frogpublic')
            .set({ users: { robert: { added: true } }, isPublic: true, clubUid: 'clubby' });
        await db
            .collection('Clubs')
            .doc('clubby')
            .set({
                isPublic: true,
                members: {
                    robert: {
                        admin: true,
                    },
                },
            });
        await db.collection('Clubs').doc('clubby').collection('Coaches').doc('coach').set({
            clubUid: 'clubby',
            uid: 'coach',
        });
        await db.collection('Clubs').doc('clubby').collection('News').doc('news').set({
            clubUid: 'clubby',
            uid: 'news',
        });
        await firebase.assertSucceeds(db.collection('Teams').doc('frogpublic').get());
        await firebase.assertSucceeds(db.collection('Clubs').doc('clubby').get());
        await firebase.assertSucceeds(db.collection('Clubs').doc('clubby').collection('Coaches').doc('coach').get());
        await firebase.assertSucceeds(db.collection('Clubs').doc('clubby').collection('News').doc('news').get());
        await firebase.assertSucceeds(db.collection('Clubs').doc('clubby').collection('Coaches').get());
        await firebase.assertSucceeds(db.collection('Clubs').doc('clubby').collection('News').get());
        const aliceDb = authedApp({ uid: 'alice' });
        await firebase.assertSucceeds(aliceDb.collection('Teams').doc('frogpublic').get());
        await firebase.assertSucceeds(aliceDb.collection('Clubs').doc('clubby').get());
        await firebase.assertSucceeds(
            aliceDb.collection('Clubs').doc('clubby').collection('Coaches').doc('coach').get(),
        );
        await firebase.assertSucceeds(aliceDb.collection('Clubs').doc('clubby').collection('News').doc('news').get());
        await firebase.assertSucceeds(aliceDb.collection('Clubs').doc('clubby').collection('Coaches').get());
        await firebase.assertSucceeds(aliceDb.collection('Clubs').doc('clubby').collection('News').get());
        const dbAnon = authedApp();
        await firebase.assertSucceeds(dbAnon.collection('Teams').doc('frogpublic').get());
        await firebase.assertSucceeds(dbAnon.collection('Clubs').doc('clubby').get());
        await firebase.assertSucceeds(
            dbAnon.collection('Clubs').doc('clubby').collection('Coaches').doc('coach').get(),
        );
        await firebase.assertSucceeds(dbAnon.collection('Clubs').doc('clubby').collection('News').doc('news').get());
        await firebase.assertSucceeds(dbAnon.collection('Clubs').doc('clubby').collection('Coaches').get());
        await firebase.assertSucceeds(dbAnon.collection('Clubs').doc('clubby').collection('News').get());

        await firebase.assertSucceeds(
            db.collection('Teams').where('clubUid', '==', 'clubby').where('users.robert.added', '==', true).get(),
        );
        const stuff = await firebase.assertSucceeds(
            dbAnon.collection('Teams').where('clubUid', '==', 'clubby').where('isPublic', '==', true).get(),
        );
        expect(stuff.docs.length).is.equal(1);
    });
    it('create user profiles', async () => {
        const db = authedApp({ uid: 'alice' });
        const profile = db.collection('UserData').doc('alice');
        await firebase.assertFails(profile.set({ birthday: 'January 1' }));
        await firebase.assertSucceeds(
            profile.set({
                birthday: 'January 1',
                createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            }),
        );
    });

    it('get game requires season user', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await db
            .collection('Teams')
            .doc('team')
            .set({ admins: { alice: true }, isPublic: true });
        await firebase.assertSucceeds(
            db
                .collection('Seasons')
                .doc('season')
                .set({
                    users: {
                        alice: { added: true },
                    },
                    players: { fluff: { added: true } },
                    teamUid: 'team',
                }),
        );
        await firebase.assertSucceeds(
            db
                .collection('Teams')
                .doc('team')
                .set({
                    seasonUid: 'season',
                    uid: 'sharedGame',
                    admins: ['alice'],
                }),
        );

        const gameRef = db.collection('Games').doc('game');
        const sharedGameRef = db.collection('GamesShared').doc('sharedGame');
        await firebase.assertSucceeds(
            db.runTransaction(async (t) => {
                await t.set(sharedGameRef, {
                    seasonUid: 'season',
                    uid: 'sharedGame',
                });

                await t.set(gameRef, {
                    seasonUid: 'season',
                    sharedDataUid: 'sharedGame',
                    teamUid: 'team',
                });
                return;
            }),
        );
        await firebase.assertSucceeds(db.collection('Games').doc('game').get());
        const dbRobert = authedApp({ uid: 'robert', email_verified: true });
        await firebase.assertFails(dbRobert.collection('Games').doc('game').get());
    });

    it('get opponents', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertSucceeds(
            db
                .collection('Teams')
                .doc('team')
                .set({
                    seasonUid: 'season',
                    uid: 'team',
                    admins: ['alice'],
                }),
        );

        await firebase.assertSucceeds(
            db.collection('Teams').doc('team').collection('Opponents').doc('op').set({
                name: 'season',
            }),
        );
        await firebase.assertSucceeds(db.collection('Teams').doc('team').collection('Opponents').doc('op').get());
    });
});
