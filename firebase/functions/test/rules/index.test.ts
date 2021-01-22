import * as firebase from '@firebase/rules-unit-testing';
import * as fs from 'fs';

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
    console.log('end beforeEach');
});

before(async function () {
    console.log('start before');
    await firebase.loadFirestoreRules({
        projectId: projectName,
        rules: fs.readFileSync('../firestore.rules', 'utf8'),
    });
    console.log('end before');
});

after(async function ()  {
    await Promise.all(firebase.apps().map((app) => app.delete()));
    console.log(`View rule coverage information at ${coverageUrl}\n`);
});

describe('TeamsFuse rules', function () {
    it('require users to log in before listing teams', async function ()  {
        const db = authedApp();
        const doc = db.collection('Teams').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing clubs', async function () {
        const db = authedApp();
        const doc = db.collection('Clubs').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing games', async () => {
        const db = authedApp();
        const doc = db.collection('Games').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing games shared', async () => {
        const db = authedApp();
        const doc = db.collection('GamesShared').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing invites', async () => {
        const db = authedApp();
        const doc = db.collection('Invites').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('everyone can list league', async () => {
        const db = authedApp();
        const doc = db.collection('League').doc('frog');
        await firebase.assertSucceeds(doc.get());
    });
    it('everyone can list league divison', async () => {
        const db = authedApp();
        const doc = db.collection('LeagueDivision').doc('frog');
        await firebase.assertSucceeds(doc.get());
    });
    it('everyone can list league season', async () => {
        const db = authedApp();
        const doc = db.collection('LeagueSeason').doc('frog');
        await firebase.assertSucceeds(doc.get());
    });
    it('everyone can list league team', async () => {
        const db = authedApp();
        const doc = db.collection('LeagueTeam').doc('frog');
        await firebase.assertSucceeds(doc.get());
    });
    it('require users to log in before listing message recipients', async () => {
        const db = authedApp();
        const doc = db.collection('MessageRecipients').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing messages', async () => {
        const db = authedApp();
        const doc = db.collection('Messages').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing players', async () => {
        const db = authedApp();
        const doc = db.collection('Players').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to log in before listing seasons', async () => {
        const db = authedApp();
        const doc = db.collection('Seasons').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to be in the team to get team', async () => {
        const db = authedApp();
        const doc = db.collection('Teams').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to be logged in to get team', async () => {
        const db = authedApp();
        const doc = db.collection('Seaons').doc('frog');
        await firebase.assertFails(doc.get());
    });
    it('require users to be in the teams to get team', async () => {
        const db = authedApp({ uid: 'alice' });
        await db
            .collection('Teams')
            .doc('frog')
            .set({ users: { alice: { added: true } } });
        //const doc = db.collection("Teams").doc("frog");
        await firebase.assertSucceeds(db.collection('Teams').doc('frog').get());
    });
    it('require users to be in the season to get the season', async () => {
        const db = authedApp({ uid: 'alice' });
        await db
            .collection('Seasons')
            .doc('frog')
            .set({ user: { alice: { added: true } } });
        //const doc = db.collection("Teams").doc("frog");
        await firebase.assertSucceeds(db.collection('Seasons').doc('frog').get());
    });
    it('should enforce the createdAt date in user profiles', async () => {
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
});