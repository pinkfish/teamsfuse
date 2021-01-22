import * as sinon from 'sinon';
import firebaseFunctionsTest from 'firebase-functions-test';
import { expect } from 'chai';
import * as nodemailer from 'nodemailer';
import { AxiosInstance } from 'axios';
import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';

const projectName = 'teamsfuse';

admin.initializeApp();

const test = firebaseFunctionsTest({
    projectId: projectName,
});

test.mockConfig({
    mailgun: {
        apikey: 'frog',
        domain: 'frog.com',
    },
    links: {
        key: 'rabbit',
    },
});

import * as dl from '../../ts/util/dynamiclinks';

import { onWrite } from '../../ts/db/invites/onwrite.f';
import * as mailgun from '../../ts/util/mailgun';

describe('Invite Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        test.cleanup();
        sinon.restore();
        return;
    });

    it('team invite', async () => {
        await sendTheMail({
            sentbyUid: 'sentByFluff',
            name: 'Fluffy',
            teamUid: 'team',
            teamName: 'My Team Name',
            seasonName: '2021',
            email: 'frog@froggy.com',
            uid: '1',
            type: 'Team',
        });
    }).timeout(10000);

    it('club invite', async () => {
        await sendTheMail({
            sentbyUid: 'sentByFluff',
            name: 'Fluffy',
            clubUid: 'club',
            clubName: 'My Club Name',
            email: 'frog@froggy.com',
            uid: '1',
            admin: false,
            type: 'Club',
        });
    }).timeout(10000);

    it('player invite', async () => {
        await sendTheMail({
            sentbyUid: 'sentByFluff',
            name: 'Fluffy',
            playerUid: 'player',
            playerName: 'My Player Name',
            email: 'frog@froggy.com',
            uid: '1',
            type: 'Player',
        });
    }).timeout(10000);

    async function sendTheMail(inviteData: any) {
        const inviteId: string = uuid();
        inviteData['uid'] = inviteId;
        const getMailTransportOverride = sinon.stub(mailgun.mailTransport, 'transport');
        const dynamicLinkStub = sinon.stub(dl, 'getShortUrlDynamicLink');
        dynamicLinkStub.callsFake((url: string, api: AxiosInstance) => {
            return new Promise((resolve, reject) => {
                resolve('bits');
            });
        });
        try {
            const account = await nodemailer.createTestAccount();

            // Create a SMTP transporter object
            getMailTransportOverride.returns(
                nodemailer.createTransport({
                    host: account.smtp.host,
                    port: account.smtp.port,
                    secure: account.smtp.secure,
                    auth: {
                        user: account.user,
                        pass: account.pass,
                    },
                }),
            );

            const doc = test.firestore.makeDocumentSnapshot(inviteData, 'environments/dev/Invites/' + inviteId);

            // Setup some data to be queried first.
            await admin.firestore().collection('UserData').doc('sentByFluff').set({
                displayName: 'Fluff',
                email: 'fluff@example.com',
            });
            await admin.firestore().collection('Teams').doc('team').set({
                name: 'Lookup TeamName',
                photourl: null,
            });
            await admin.firestore().collection('Clubs').doc('club').set({
                name: 'Lookup ClubName',
                photourl: null,
            });
            await admin.firestore().collection('Players').doc('player').set({
                name: 'Lookup PlayerName',
                photourl: null,
            });
            await admin.firestore().collection('Invites').doc(inviteId).set(doc.data());

            try {
                const change = test.makeChange(null, doc);
                await test.wrap(onWrite)(change, {
                    auth: {
                        uid: 'me',
                    },
                    authType: 'USER',
                });
                expect(getMailTransportOverride.calledOnce).to.be.true;
                const data = await admin.firestore().collection('Invites').doc(inviteId).get();
                expect(data).to.not.be.null;
                if (data !== null && data !== undefined) {
                    expect(data.exists).to.be.true;
                    const myData = data.data();
                    expect(myData).to.not.be.null;
                    if (myData !== undefined && myData !== null) {
                        expect(myData.emailedInvite).to.be.true;
                    }
                }
                await admin.firestore().collection('Invites').doc(inviteId).delete();
            } catch (e) {
                console.log(e);
                console.log(e.stack);
                await admin.firestore().collection('Invites').doc(inviteId).delete();
                throw e;
            }
            return;
        } catch (e) {
            throw e;
        } finally {
            dynamicLinkStub.restore();
            getMailTransportOverride.restore();
        }
    }
});
