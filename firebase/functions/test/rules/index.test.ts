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
    it('create player no uid', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: { alice: { added: true } }, playerType: 'player' }),
        );
    });
    it('create player normal', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertSucceeds(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: { alice: { added: true } }, uid: 'frog', playerType: 'player' }),
        );
    });
    it('create player update photoUrl', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertSucceeds(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: { alice: { added: true } }, uid: 'frog', playerType: 'player' }),
        );
        await firebase.assertSucceeds(db.collection('Players').doc('frog').update({ photoUrl: 'player' }));
    });

    it('create player user + opponent', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: { alice: { added: true } }, uid: 'frog', opponentUid: 'fail', playerType: 'opponent' }),
        );
    });
    it('create player user + game', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: { alice: { added: true } }, uid: 'frog', gameUid: 'fail', playerType: 'guest' }),
        );
    });
    it('create player game + opponent', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ uid: 'frog', gameUid: 'fail', opponentUid: 'fail', playerType: 'opponent' }),
        );
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ uid: 'frog', gameUid: 'fail', opponentUid: 'fail', playerType: 'guest' }),
        );
    });
    it('create player empty users', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db.collection('Players').doc('frog').set({ users: {}, uid: 'frog', playerType: 'player' }),
        );
    });
    it('create player opponent null', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: {}, uid: 'frog', opponentUid: null, playerType: 'opponent' }),
        );
    });
    it('create player game null', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db.collection('Players').doc('frog').set({ users: {}, uid: 'frog', gameUid: null, playerType: 'guest' }),
        );
    });
    it('create player game', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertSucceeds(
            db.collection('Players').doc('frog').set({ users: {}, uid: 'frog', gameUid: '1234', playerType: 'guest' }),
        );
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: {}, uid: 'frog', gameUid: '1234', playerType: 'opponent' }),
        );
        await firebase.assertSucceeds(
            db.collection('Players').doc('frog').set({ uid: 'frog', gameUid: '1234', playerType: 'guest' }),
        );
    });
    it('create player opponent', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertSucceeds(
            db
                .collection('Players')
                .doc('frog')
                .set({ users: {}, uid: 'frog', opponentUid: '1234', teamUid: '1234', playerType: 'opponent' }),
        );
        await firebase.assertSucceeds(
            db
                .collection('Players')
                .doc('frog')
                .set({ uid: 'frog', opponentUid: '1234', teamUid: '1234', playerType: 'opponent' }),
        );
        await firebase.assertFails(
            db
                .collection('Players')
                .doc('frog')
                .set({ uid: 'frog', opponentUid: '1234', teamUid: '1234', playerType: 'player' }),
        );
        await firebase.assertSucceeds(
            db.collection('Players').doc('ERiHpw8BYZ5pd6sodXUB').set({
                name: 'Unknown',
                uid: 'ERiHpw8BYZ5pd6sodXUB',
                playerType: 'opponent',
                perSeason: {},
                isPublic: true,
                opponentUid: 'whfuCWoIODiFwlBpZewD',
                teamUid: 'lqxpi9dfOEvK02G5PbXi',
            }),
        );
    });
    it('create player opponent team only', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db.collection('Players').doc('frog').set({ users: {}, uid: 'frog', teamUid: '1234' }),
        );
    });
    it('create player opponent opponent only', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await firebase.assertFails(
            db.collection('Players').doc('frog').set({ users: {}, uid: 'frog', opponentUid: '1234' }),
        );
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
            .set({ uid: 'frog', admins: { alice: { added: true } } });
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
                uid: 'frogpublic',
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
                uid: 'team',
                admins: {
                    robert: true,
                },
            });
        await db
            .collection('Seasons')
            .doc('frog')
            .set({
                uid: 'frog',
                users: { robert: { added: true } },
                players: { fluff: { added: true } },
                teamUid: 'team',
            });
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
                uid: 'team',
                admins: {
                    robert: true,
                },
            });
        await db
            .collection('Seasons')
            .doc('frogpublic')
            .set({
                uid: 'frogpublic',
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
            .set({
                uid: 'frogpublic',
                users: { robert: { added: true } },
                isPublic: true,
                clubUid: 'clubby',
                admins: { robert: true },
            });
        await db
            .collection('Clubs')
            .doc('clubby')
            .set({
                uid: 'clubby',
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
        await firebase.assertFails(profile.set({ uid: 'alice', birthday: 'January 1' }));
        await firebase.assertSucceeds(
            profile.set({
                uid: 'alice',
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
            .set({ uid: 'team', admins: { alice: true }, isPublic: true });
        await firebase.assertSucceeds(
            db
                .collection('Seasons')
                .doc('season')
                .set({
                    uid: 'season',
                    users: {
                        alice: { added: true },
                        other: { added: true },
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
                    uid: 'team',
                    admins: { alice: true },
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
                    uid: 'game',
                    seasonUid: 'season',
                    sharedDataUid: 'sharedGame',
                    teamUid: 'team',
                });
                return;
            }),
        );
        await firebase.assertSucceeds(db.collection('Games').doc('game').get());
        // Make sure we can update the game too.
        await firebase.assertSucceeds(
            db.collection('Games').doc('game').update({
                time: 1234,
                uid: 'game',
            }),
        );
        const dbRobert = authedApp({ uid: 'robert', email_verified: true });
        await firebase.assertFails(dbRobert.collection('Games').doc('game').get());
        await firebase.assertFails(
            dbRobert.collection('Games').doc('game').update({
                time: 12345,
            }),
        );
        await firebase.assertFails(
            dbRobert
                .collection('Games')
                .doc('game')
                .update({
                    players: {
                        fluff: { added: true },
                        biggles: { added: true },
                    },
                }),
        );
        const dbOther = authedApp({ uid: 'other', email_verified: true });
        await firebase.assertFails(
            dbOther.collection('Games').doc('game').update({
                time: 12345,
            }),
        );
        await firebase.assertSucceeds(
            dbOther
                .collection('Games')
                .doc('game')
                .update({
                    players: {
                        fluff: { added: true },
                        biggles: { added: true },
                    },
                }),
        );
        await firebase.assertFails(
            dbOther
                .collection('Games')
                .doc('game')
                .update({
                    players: {
                        fluff: { added: true },
                    },
                }),
        );
        // Admin can delete a player.
        await firebase.assertSucceeds(
            db
                .collection('Games')
                .doc('game')
                .update({
                    players: {
                        fluff: { added: true },
                    },
                }),
        );
    });

    it('get game events', async () => {
        const db = authedApp({ uid: 'alice', email_verified: true });
        await db
            .collection('Teams')
            .doc('team')
            .set({ uid: 'team', admins: { alice: true }, isPublic: true });
        await firebase.assertSucceeds(
            db
                .collection('Seasons')
                .doc('season')
                .set({
                    uid: 'season',
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
                    uid: 'team',
                    admins: { alice: true },
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
                    uid: 'game',
                    seasonUid: 'season',
                    sharedDataUid: 'sharedGame',
                    teamUid: 'team',
                });
                return;
            }),
        );
        await firebase.assertSucceeds(db.collection('Games').doc('game').get());
        await firebase.assertSucceeds(db.collection('Games').doc('game').collection('GameEvents').get());
        await firebase.assertSucceeds(
            db.collection('Games').doc('game').collection('GameEvents').doc('ev').set({
                uid: 'ev',
            }),
        );
        await firebase.assertSucceeds(db.collection('Games').doc('game').collection('GameEvents').get());
        const dbRobert = authedApp({ uid: 'robert', email_verified: true });
        await firebase.assertSucceeds(dbRobert.collection('Games').doc('game').collection('GameEvents').get());
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
