import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';
import { DocumentSnapshot } from '@google-cloud/firestore';

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

import { onMessageWrite } from '../../ts/db/messages/update.f';

describe('Teams Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    async function createMessageRecipient(messageId: string, userId: string): Promise<DocumentSnapshot> {
        const recipientDocId = uuid();

        await admin.firestore().collection('MessageRecipients').doc(recipientDocId).set({
            name: 'Current Season',
            uid: recipientDocId,
            messageId: messageId,
            userId: userId,
        });

        return admin.firestore().collection('MessageRecipients').doc(recipientDocId).get();
    }

    async function createMessage(): Promise<DocumentSnapshot> {
        const messageDocId = uuid();

        // Setup some data to be queried first.
        await admin.firestore().collection('Messages').doc(messageDocId).set({
            name: 'Lookup TeamName',
            recipients: {},
        });

        return await admin.firestore().collection('Messages').doc(messageDocId).get();
    }

    it('copy recipient', async () => {
        const message = await createMessage();
        const messageRecipient = await createMessageRecipient(message.id, 'me');

        try {
            await test.wrap(onMessageWrite)(test.makeChange(messageRecipient, messageRecipient), {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            const newData = await admin.firestore().collection('Messages').doc(message.id).get();
            const newDataData = newData.data();
            if (newDataData !== null && newDataData !== undefined) {
                expect(newDataData.recipients.me).to.be.deep.equal(messageRecipient.data());
            }
            await message.ref.delete();
            await messageRecipient.ref.delete();
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await message.ref.delete();
            await messageRecipient.ref.delete();
            throw e;
        }

        return;
    }).timeout(10000);
});
