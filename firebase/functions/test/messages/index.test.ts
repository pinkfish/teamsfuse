import * as sinon from 'sinon';
import { firebaseTest } from '../test_util/firebase';
import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';
import { DocumentSnapshot } from '@google-cloud/firestore';
import * as mailgun from '../../ts/util/mailgun';
import * as nodemailer from 'nodemailer';
import * as dl from '../../ts/util/dynamiclinks';
import SMTPTransport from 'nodemailer/lib/smtp-transport';
import { clearFirestoreData } from '@firebase/rules-unit-testing';
import chai, { expect, should } from 'chai';
import SinonChai from 'sinon-chai';
import { createSeasonAndTeam, createPlayer, createUser } from '../test_util/datacreation';

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

import { onMessageCreate } from '../../ts/db/messages/create.f';
import { onMessageUpdate } from '../../ts/db/messages/update.f';

describe('Messages', () => {
    let spy: sinon.SinonStub<[mailOptions: nodemailer.SendMailOptions], Promise<SMTPTransport.SentMessageInfo>>;

    before(() => {
        spy = sinon.stub(mailgun, 'sendMail');
        const dynamicLinkStub = sinon.stub(dl, 'getShortLink');
        dynamicLinkStub.callsFake((subject: string, path: string) => {
            return new Promise((resolve, reject) => {
                resolve('http://bits.link/stuff' + path);
            });
        });

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

    async function createMessageRecipient(messageId: string, userId: string): Promise<DocumentSnapshot> {
        const recipientDocId = uuid();

        await admin.firestore().collection('MessageRecipients').doc(recipientDocId).set({
            name: 'Current Season',
            uid: recipientDocId,
            messageId: messageId,
            userId: userId,
            fromUid: 'fromPlayer',
            playerId: 'toPlayer',
            state: 'Unread',
        });

        return admin.firestore().collection('MessageRecipients').doc(recipientDocId).get();
    }

    async function createMessage(teamUid: string): Promise<DocumentSnapshot> {
        const messageDocId = uuid();

        // Setup some data to be queried first.
        await admin.firestore().collection('Messages').doc(messageDocId).set({
            name: 'Lookup TeamName',
            recipients: {},
            teamUid: teamUid,
            fromUid: 'fromPlayer',
            subject: 'Subject of fluff',
            timeSent: 12456,
        });
        await admin.firestore().collection('Messages').doc(messageDocId).collection('Messages').doc(messageDocId).set({
            body: '<p>Do the body stuff you body <a href="ginging">',
        });

        return await admin.firestore().collection('Messages').doc(messageDocId).get();
    }

    it('copy recipient - create', async () => {
        spy.reset();
        const message = await createMessage('team');
        const messageRecipient = await createMessageRecipient(message.id, 'me');

        await test.wrap(onMessageCreate)(messageRecipient, {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });
        const newData = await admin.firestore().collection('Messages').doc(message.id).get();
        const newDataData = newData.data();
        expect(newDataData!.recipients.me).to.be.deep.equal(messageRecipient.data());
        sinon.assert.notCalled(spy);

        return;
    });

    it('copy recipient - update', async () => {
        spy.reset();
        const message = await createMessage('team');
        const messageRecipient = await createMessageRecipient(message.id, 'me');

        await test.wrap(onMessageUpdate)(test.makeChange(messageRecipient, messageRecipient), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });
        const newData = await admin.firestore().collection('Messages').doc(message.id).get();
        const newDataData = newData.data();
        expect(newDataData!.recipients.me).to.be.deep.equal(messageRecipient.data());
        sinon.assert.notCalled(spy);

        return;
    });

    it('delete extra recipient', async () => {
        spy.reset();
        const message = await createMessage('team');
        const messageRecipient = await createMessageRecipient(message.id, 'me');
        await createMessageRecipient(message.id, 'me');

        await test.wrap(onMessageCreate)(messageRecipient, {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });
        const newData = await admin.firestore().collection('Messages').doc(message.id).get();
        const newDataData = newData.data();
        expect(newDataData!.recipients.me).to.be.deep.equal(messageRecipient.data());
        sinon.assert.notCalled(spy);

        // Do a search and make sure there is only one.
        const result = await admin
            .firestore()
            .collection('MessageRecipients')
            .where('userId', '==', 'me')
            .where('messageId', '==', message.id)
            .get();

        expect(result.docs.length).is.equal(1);
        return;
    });

    it('send mail', async () => {
        spy.reset();
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const toUser = await createUser(['1234token']);
        const fromUser = await createUser(['fromToken']);
        await createPlayer([toUser.id], 'toPlayer');
        await createPlayer([fromUser.id], 'fromPlayer');
        const message = await createMessage(teamAndSeason.team.id);
        const messageRecipient = await createMessageRecipient(message.id, 'me');

        await test.wrap(onMessageCreate)(messageRecipient, {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });
        const newData = await admin.firestore().collection('Messages').doc(message.id).get();
        const newDataData = newData.data();
        expect(newDataData!.recipients.me).to.be.deep.equal(messageRecipient.data());
        spy.getCall(0).should.have.been.calledWith({
            subject: '[Lookup TeamName] Subject of fluff',
            text:
                'Subject: Subject of fluff<\n' +
                'From:    Player fromPlayer in Lookup TeamName</h4>\n' +
                'Sent at: Wednesday, December 31, 1969, 4:00 PM Pacific Standard Time</h4>\n' +
                'Link:    http://bits.link/stuff/Message/View/' +
                messageRecipient.id +
                '\n' +
                '\n' +
                '&lt;p&gt;Do the body stuff you body &lt;a href&#x3D;&quot;ginging&quot;&gt;\n' +
                '\n' +
                '\n' +
                '-----\n' +
                'TeamsFuse is an app to help organize your sports teams.\n' +
                'https://www.teamsfuse.com\n' +
                '\n' +
                'iPhone download: https://apps.apple.com/us/app/team-fuse/id1374615208\n' +
                'Android download: https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse\n',
            html:
                '<p><img src="" width="200" height="200" style="padding: 0 15px; float: left" /></p>\n' +
                '\n' +
                '<p style="margin-top: 20px"></p>\n' +
                '\n' +
                '<h2><a href="http://bits.link/stuff/Message/View/' +
                messageRecipient.id +
                '">Subject of fluff</a></h2>\n' +
                '<h4>From: Player fromPlayer in Lookup TeamName</h4>\n' +
                '<h4>Sent at: Wednesday, December 31, 1969, 4:00 PM Pacific Standard Time</h4>\n' +
                '<p>' +
                '&lt;p&gt;Do the body stuff you body &lt;a href&#x3D;&quot;ginging&quot;&gt;</p>\n' +
                '<br clear="both" />\n' +
                '\n' +
                '<hr\n' +
                '    style="\n' +
                '        border: 0;\n' +
                '        height: 1px;\n' +
                '        background-image: linear-gradient(to right, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.75), rgba(0, 0, 0, 0));\n' +
                '    "\n' +
                '/>\n' +
                '<p>\n' +
                '    <i><a href="https://www.teamsfuse.com">TeamsFuse</a></i> is an app to help organize your sports teams.\n' +
                '</p>\n' +
                '\n' +
                '<p></p>\n' +
                '<p>\n' +
                '    <a href="https://apps.apple.com/us/app/team-fuse/id1374615208">\n' +
                '        <img src="cid:apple-store" width="160" height="54" />\n' +
                '    </a>\n' +
                '    &nbsp;&nbsp;\n' +
                '    <a href="https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse">\n' +
                '        <img src="cid:google-store" width="153" height="46" />\n' +
                '    </a>\n' +
                '</p>\n',
            from: '"Player fromPlayer <' + messageRecipient.id + '@email.teamsfuse.com>',
            to: 'test@test.com',
            attachments: mailAttachments,
        });

        return;
    });
});

export const mailAttachments = [
    {
        filename: 'apple-store-badge.png',
        path: 'lib/ts/templates/img/apple-store-badge.png',
        cid: 'apple-store',
    },
    {
        filename: 'google-store-badge.png',
        path: 'lib/ts/templates/img/google-play-badge.png',
        cid: 'google-store',
    },
    {
        filename: 'player.jpg',
        content:
            'PCFET0NUWVBFIGh0bWw+CjxodG1sPgogIDxoZWFkPgogICAgPCEtLQogICAgSWYgeW91IGFyZSBzZXJ2aW5nIHlvdXIgd2ViIGFwcCBpbiBhIHBhdGggb3RoZXIgdGhhbiB0aGUgcm9vdCwgY2hhbmdlIHRoZQogICAgaHJlZiB2YWx1ZSBiZWxvdyB0byByZWZsZWN0IHRoZSBiYXNlIHBhdGggeW91IGFyZSBzZXJ2aW5nIGZyb20uCgogICAgVGhlIHBhdGggcHJvdmlkZWQgYmVsb3cgaGFzIHRvIHN0YXJ0IGFuZCBlbmQgd2l0aCBhIHNsYXNoICIvIiBpbiBvcmRlciBmb3IKICAgIGl0IHRvIHdvcmsgY29ycmVjdGx5LgoKICAgIEZvcmUgbW9yZSBkZXRhaWxzOgogICAgKiBodHRwczovL2RldmVsb3Blci5tb3ppbGxhLm9yZy9lbi1VUy9kb2NzL1dlYi9IVE1ML0VsZW1lbnQvYmFzZQogIC0tPgogICAgPGJhc2UgaHJlZj0iLyIgLz4KCiAgICA8bWV0YSBjaGFyc2V0PSJVVEYtOCIgLz4KICAgIDxtZXRhIGNvbnRlbnQ9IklFPUVkZ2UiIGh0dHAtZXF1aXY9IlgtVUEtQ29tcGF0aWJsZSIgLz4KICAgIDxtZXRhIG5hbWU9ImRlc2NyaXB0aW9uIiBjb250ZW50PSJBIG5ldyBGbHV0dGVyIHByb2plY3QuIiAvPgoKICAgIDwhLS0gaU9TIG1ldGEgdGFncyAmIGljb25zIC0tPgogICAgPG1ldGEgbmFtZT0iYXBwbGUtbW9iaWxlLXdlYi1hcHAtY2FwYWJsZSIgY29udGVudD0ieWVzIiAvPgogICAgPG1ldGEgbmFtZT0iYXBwbGUtbW9iaWxlLXdlYi1hcHAtc3RhdHVzLWJhci1zdHlsZSIgY29udGVudD0iYmxhY2siIC8+CiAgICA8bWV0YSBuYW1lPSJhcHBsZS1tb2JpbGUtd2ViLWFwcC10aXRsZSIgY29udGVudD0iZmx1dHRlcl9mdXNlIiAvPgogICAgPGxpbmsgcmVsPSJhcHBsZS10b3VjaC1pY29uIiBocmVmPSJpY29ucy9pY29uLTE5Mi5wbmciIC8+CgogICAgPCEtLSBGYXZpY29uIC0tPgogICAgPGxpbmsgcmVsPSJpY29uIiB0eXBlPSJpbWFnZS9wbmciIGhyZWY9ImZhdmljb24ucG5nIiAvPgoKICAgIDx0aXRsZT5mbHV0dGVyX2Z1c2U8L3RpdGxlPgogICAgPGxpbmsgcmVsPSJtYW5pZmVzdCIgaHJlZj0ibWFuaWZlc3QuanNvbiIgLz4KICA8L2hlYWQ+CiAgPGJvZHk+CiAgICA8IS0tIFRoaXMgc2NyaXB0IGluc3RhbGxzIHNlcnZpY2Vfd29ya2VyLmpzIHRvIHByb3ZpZGUgUFdBIGZ1bmN0aW9uYWxpdHkgdG8KICAgICAgIGFwcGxpY2F0aW9uLiBGb3IgbW9yZSBpbmZvcm1hdGlvbiwgc2VlOgogICAgICAgaHR0cHM6Ly9kZXZlbG9wZXJzLmdvb2dsZS5jb20vd2ViL2Z1bmRhbWVudGFscy9wcmltZXJzL3NlcnZpY2Utd29ya2VycyAtLT4KICAgIDxzY3JpcHQ+CiAgICAgIGlmICgic2VydmljZVdvcmtlciIgaW4gbmF2aWdhdG9yKSB7CiAgICAgICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoImZsdXR0ZXItZmlyc3QtZnJhbWUiLCBmdW5jdGlvbiAoKSB7CiAgICAgICAgICBuYXZpZ2F0b3Iuc2VydmljZVdvcmtlci5yZWdpc3RlcigiZmx1dHRlcl9zZXJ2aWNlX3dvcmtlci5qcyIpOwogICAgICAgIH0pOwogICAgICB9CiAgICA8L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzcuMjAuMC9maXJlYmFzZS1hcHAuanMiPjwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Imh0dHBzOi8vd3d3LmdzdGF0aWMuY29tL2ZpcmViYXNlanMvNy4xNy4xL2ZpcmViYXNlLWZpcmVzdG9yZS5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1hdXRoLmpzIj48L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzguMi40L2ZpcmViYXNlLW1lc3NhZ2luZy5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1wZXJmb3JtYW5jZS5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1zdG9yYWdlLmpzIj48L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzguMi40L2ZpcmViYXNlLXJlbW90ZS1jb25maWcuanMiPjwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Imh0dHBzOi8vd3d3LmdzdGF0aWMuY29tL2ZpcmViYXNlanMvOC4yLjQvZmlyZWJhc2UtYW5hbHl0aWNzLmpzIj48L3NjcmlwdD4KCiAgICA8c2NyaXB0PgogICAgICAvLyBZb3VyIHdlYiBhcHAncyBGaXJlYmFzZSBjb25maWd1cmF0aW9uCiAgICAgIHZhciBmaXJlYmFzZUNvbmZpZyA9IHsKICAgICAgICBhcGlLZXk6ICJBSXphU3lCZGhTV1NPRXZuVE1ITURmMGJNRUliOGk2NHVWY1dMM1UiLAogICAgICAgIGF1dGhEb21haW46ICJ0ZWFtc2Z1c2UuZmlyZWJhc2VhcHAuY29tIiwKICAgICAgICBkYXRhYmFzZVVSTDogImh0dHBzOi8vdGVhbXNmdXNlLmZpcmViYXNlaW8uY29tIiwKICAgICAgICBwcm9qZWN0SWQ6ICJ0ZWFtc2Z1c2UiLAogICAgICAgIHN0b3JhZ2VCdWNrZXQ6ICJ0ZWFtc2Z1c2UuYXBwc3BvdC5jb20iLAogICAgICAgIG1lc3NhZ2luZ1NlbmRlcklkOiAiNDAwMTk5ODk3NjgzIiwKICAgICAgICBhcHBJZDogIjE6NDAwMTk5ODk3NjgzOndlYjphNzZiOWM1MjNkYmVmN2E0MDhhY2E2IiwKICAgICAgfTsKICAgICAgLy8gSW5pdGlhbGl6ZSBGaXJlYmFzZQogICAgICBmaXJlYmFzZS5pbml0aWFsaXplQXBwKGZpcmViYXNlQ29uZmlnKTsKICAgIDwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Im1haW4uZGFydC5qcyIgdHlwZT0iYXBwbGljYXRpb24vamF2YXNjcmlwdCI+PC9zY3JpcHQ+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==',
        cid: 'playerimg',
        contentType: 'text/html; charset=utf-8',
        encoding: 'base64',
    },
];
