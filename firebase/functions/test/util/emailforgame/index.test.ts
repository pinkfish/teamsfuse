import * as sinon from 'sinon';
import { firebaseTest } from '../../test_util/firebase';
import chai, { should } from 'chai';
import * as admin from 'firebase-admin';
import {
    createSeasonAndTeam,
    createGame,
    createOpponent,
    createPlayer,
    createUser,
} from '../../test_util/datacreation';
import { DateTime, Settings } from 'luxon';
import * as nodemailer from 'nodemailer';
import SMTPTransport from 'nodemailer/lib/smtp-transport';
import * as email from '../../../ts/util/email';
import * as dl from '../../../ts/util/dynamiclinks';
import { DataNodeCache } from '../../../ts/util/datacache';
import { clearFirestoreData } from '@firebase/rules-unit-testing';
import SinonChai from 'sinon-chai';
import * as mailgun from '../../../ts/util/mailgun';

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

import { emailForGame, ChangedData } from '../../../ts/util/notifyforgame';

const mailAttachments = [
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
        filename: 'team.jpg',
        content:
            'PCFET0NUWVBFIGh0bWw+CjxodG1sPgogIDxoZWFkPgogICAgPCEtLQogICAgSWYgeW91IGFyZSBzZXJ2aW5nIHlvdXIgd2ViIGFwcCBpbiBhIHBhdGggb3RoZXIgdGhhbiB0aGUgcm9vdCwgY2hhbmdlIHRoZQogICAgaHJlZiB2YWx1ZSBiZWxvdyB0byByZWZsZWN0IHRoZSBiYXNlIHBhdGggeW91IGFyZSBzZXJ2aW5nIGZyb20uCgogICAgVGhlIHBhdGggcHJvdmlkZWQgYmVsb3cgaGFzIHRvIHN0YXJ0IGFuZCBlbmQgd2l0aCBhIHNsYXNoICIvIiBpbiBvcmRlciBmb3IKICAgIGl0IHRvIHdvcmsgY29ycmVjdGx5LgoKICAgIEZvcmUgbW9yZSBkZXRhaWxzOgogICAgKiBodHRwczovL2RldmVsb3Blci5tb3ppbGxhLm9yZy9lbi1VUy9kb2NzL1dlYi9IVE1ML0VsZW1lbnQvYmFzZQogIC0tPgogICAgPGJhc2UgaHJlZj0iLyIgLz4KCiAgICA8bWV0YSBjaGFyc2V0PSJVVEYtOCIgLz4KICAgIDxtZXRhIGNvbnRlbnQ9IklFPUVkZ2UiIGh0dHAtZXF1aXY9IlgtVUEtQ29tcGF0aWJsZSIgLz4KICAgIDxtZXRhIG5hbWU9ImRlc2NyaXB0aW9uIiBjb250ZW50PSJBIG5ldyBGbHV0dGVyIHByb2plY3QuIiAvPgoKICAgIDwhLS0gaU9TIG1ldGEgdGFncyAmIGljb25zIC0tPgogICAgPG1ldGEgbmFtZT0iYXBwbGUtbW9iaWxlLXdlYi1hcHAtY2FwYWJsZSIgY29udGVudD0ieWVzIiAvPgogICAgPG1ldGEgbmFtZT0iYXBwbGUtbW9iaWxlLXdlYi1hcHAtc3RhdHVzLWJhci1zdHlsZSIgY29udGVudD0iYmxhY2siIC8+CiAgICA8bWV0YSBuYW1lPSJhcHBsZS1tb2JpbGUtd2ViLWFwcC10aXRsZSIgY29udGVudD0iZmx1dHRlcl9mdXNlIiAvPgogICAgPGxpbmsgcmVsPSJhcHBsZS10b3VjaC1pY29uIiBocmVmPSJpY29ucy9pY29uLTE5Mi5wbmciIC8+CgogICAgPCEtLSBGYXZpY29uIC0tPgogICAgPGxpbmsgcmVsPSJpY29uIiB0eXBlPSJpbWFnZS9wbmciIGhyZWY9ImZhdmljb24ucG5nIiAvPgoKICAgIDx0aXRsZT5mbHV0dGVyX2Z1c2U8L3RpdGxlPgogICAgPGxpbmsgcmVsPSJtYW5pZmVzdCIgaHJlZj0ibWFuaWZlc3QuanNvbiIgLz4KICA8L2hlYWQ+CiAgPGJvZHk+CiAgICA8IS0tIFRoaXMgc2NyaXB0IGluc3RhbGxzIHNlcnZpY2Vfd29ya2VyLmpzIHRvIHByb3ZpZGUgUFdBIGZ1bmN0aW9uYWxpdHkgdG8KICAgICAgIGFwcGxpY2F0aW9uLiBGb3IgbW9yZSBpbmZvcm1hdGlvbiwgc2VlOgogICAgICAgaHR0cHM6Ly9kZXZlbG9wZXJzLmdvb2dsZS5jb20vd2ViL2Z1bmRhbWVudGFscy9wcmltZXJzL3NlcnZpY2Utd29ya2VycyAtLT4KICAgIDxzY3JpcHQ+CiAgICAgIGlmICgic2VydmljZVdvcmtlciIgaW4gbmF2aWdhdG9yKSB7CiAgICAgICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoImZsdXR0ZXItZmlyc3QtZnJhbWUiLCBmdW5jdGlvbiAoKSB7CiAgICAgICAgICBuYXZpZ2F0b3Iuc2VydmljZVdvcmtlci5yZWdpc3RlcigiZmx1dHRlcl9zZXJ2aWNlX3dvcmtlci5qcyIpOwogICAgICAgIH0pOwogICAgICB9CiAgICA8L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzcuMjAuMC9maXJlYmFzZS1hcHAuanMiPjwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Imh0dHBzOi8vd3d3LmdzdGF0aWMuY29tL2ZpcmViYXNlanMvNy4xNy4xL2ZpcmViYXNlLWZpcmVzdG9yZS5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1hdXRoLmpzIj48L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzguMi40L2ZpcmViYXNlLW1lc3NhZ2luZy5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1wZXJmb3JtYW5jZS5qcyI+PC9zY3JpcHQ+CiAgICA8c2NyaXB0IHNyYz0iaHR0cHM6Ly93d3cuZ3N0YXRpYy5jb20vZmlyZWJhc2Vqcy84LjIuNC9maXJlYmFzZS1zdG9yYWdlLmpzIj48L3NjcmlwdD4KICAgIDxzY3JpcHQgc3JjPSJodHRwczovL3d3dy5nc3RhdGljLmNvbS9maXJlYmFzZWpzLzguMi40L2ZpcmViYXNlLXJlbW90ZS1jb25maWcuanMiPjwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Imh0dHBzOi8vd3d3LmdzdGF0aWMuY29tL2ZpcmViYXNlanMvOC4yLjQvZmlyZWJhc2UtYW5hbHl0aWNzLmpzIj48L3NjcmlwdD4KCiAgICA8c2NyaXB0PgogICAgICAvLyBZb3VyIHdlYiBhcHAncyBGaXJlYmFzZSBjb25maWd1cmF0aW9uCiAgICAgIHZhciBmaXJlYmFzZUNvbmZpZyA9IHsKICAgICAgICBhcGlLZXk6ICJBSXphU3lCZGhTV1NPRXZuVE1ITURmMGJNRUliOGk2NHVWY1dMM1UiLAogICAgICAgIGF1dGhEb21haW46ICJ0ZWFtc2Z1c2UuZmlyZWJhc2VhcHAuY29tIiwKICAgICAgICBkYXRhYmFzZVVSTDogImh0dHBzOi8vdGVhbXNmdXNlLmZpcmViYXNlaW8uY29tIiwKICAgICAgICBwcm9qZWN0SWQ6ICJ0ZWFtc2Z1c2UiLAogICAgICAgIHN0b3JhZ2VCdWNrZXQ6ICJ0ZWFtc2Z1c2UuYXBwc3BvdC5jb20iLAogICAgICAgIG1lc3NhZ2luZ1NlbmRlcklkOiAiNDAwMTk5ODk3NjgzIiwKICAgICAgICBhcHBJZDogIjE6NDAwMTk5ODk3NjgzOndlYjphNzZiOWM1MjNkYmVmN2E0MDhhY2E2IiwKICAgICAgfTsKICAgICAgLy8gSW5pdGlhbGl6ZSBGaXJlYmFzZQogICAgICBmaXJlYmFzZS5pbml0aWFsaXplQXBwKGZpcmViYXNlQ29uZmlnKTsKICAgIDwvc2NyaXB0PgogICAgPHNjcmlwdCBzcmM9Im1haW4uZGFydC5qcyIgdHlwZT0iYXBwbGljYXRpb24vamF2YXNjcmlwdCI+PC9zY3JpcHQ+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==',
        cid: 'teamimg',
        contentType: 'text/html; charset=utf-8',
        encoding: 'base64',
    },
];
describe('Email for games', () => {
    let spy: sinon.SinonStub<[mailOptions: nodemailer.SendMailOptions], Promise<SMTPTransport.SentMessageInfo>>;

    before(() => {
        spy = sinon.stub(mailgun, 'sendMail');

        const dynamicLinkStub = sinon.stub(dl, 'getShortLink');
        dynamicLinkStub.callsFake((subject: string, path: string) => {
            return new Promise((resolve, reject) => {
                resolve('https://www.teamsfuse.com/main' + path);
            });
        });

        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
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

    it('notify - no player', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await emailForGame(
                gameDoc,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                cache,
                new ChangedData(),
            );
            sinon.assert.notCalled(spy);
        } finally {
            cache.close();
        }
    });

    it('notify - opt out', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        await createPlayer(['me', 'other'], 'player');
        const userDoc = await createUser(['1234'], 'me');

        await userDoc.ref.update({ emailUpcoming: false });

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await emailForGame(
                gameDoc,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                cache,
                new ChangedData(),
            );
            sinon.assert.notCalled(spy);
        } finally {
            cache.close();
        }
    });

    it('notify - changed', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        await createPlayer(['me', 'other'], 'player');
        await createUser(['1234'], 'me');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            const changed = new ChangedData();
            changed.arrival = true;
            await emailForGame(
                gameDoc,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                cache,
                changed,
            );
            spy.should.have.been.callCount(1);
            spy.getCall(0).should.have.been.calledWith({
                subject: '[Lookup TeamName] Game at  vs Test Opponent',
                text:
                    'Reminder for upcoming game with Lookup TeamName, details below:\n' +
                    '\n' +
                    'Arrive At   : Friday, May 25, 2018, 5:00 AM Pacific Daylight Time [changed]\n' +
                    'Start Time  : \n' +
                    'Address     : 1502 west test drive\n' +
                    'PlaceName   : Test High School\n' +
                    'PlaceNotes  : \n' +
                    'Uniform     : white/red/black\n' +
                    'Notes       : Do not drive backwards\n' +
                    '\n' +
                    'Availability\n' +
                    '  No one is going\n' +
                    '\n' +
                    '\n' +
                    'MAYBE\n' +
                    '  Player player (#42) \n' +
                    '\n' +
                    'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                    '\n' +
                    'Map: https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined\n' +
                    '\n' +
                    `https://www.teamsfuse.com/main/Game/View/${seasonDocId}/${gameDoc.id}\n` +
                    '\n' +
                    '-----\n' +
                    'TeamsFuse is an app to help organize your sports teams.\n' +
                    'https://www.teamsfuse.com\n' +
                    '\n' +
                    'iPhone download: https://apps.apple.com/us/app/team-fuse/id1374615208\n' +
                    'Android download: https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse\n',
                html:
                    'Reminder for upcoming game with <b><a href="https://www.teamsfuse.com/main/Team/View/' +
                    teamDocId +
                    '">Lookup TeamName</a></b>, details below:\n' +
                    '\n' +
                    '<img src="cid:teamimg" width="100" height="100" />\n' +
                    '\n' +
                    '<h4><a href="https://www.teamsfuse.com/main/Game/View/' +
                    seasonDocId +
                    '/' +
                    gameDoc.id +
                    '">Details</a></h4>\n' +
                    '<table>\n' +
                    '    <tr>\n' +
                    '        <td>Arrive At</td>\n' +
                    '        <td><b>Friday, May 25, 2018, 5:00 AM Pacific Daylight Time <i>[changed]</i></b></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Start Time</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Address</td>\n' +
                    '        <td>\n' +
                    '            <a href="https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined">1502 west test drive</a>\n' +
                    '        </td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Name</td>\n' +
                    '        <td>Test High School</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Notes</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Uniform</td>\n' +
                    '        <td>white/red/black</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Notes</td>\n' +
                    '        <td>Do not drive backwards</td>\n' +
                    '    </tr>\n' +
                    '</table>\n' +
                    '\n' +
                    '<h4>Availability</h4>\n' +
                    ' <b>No one is going</b>\n' +
                    '  \n' +
                    '<b>Maybe</b>\n' +
                    '<ul>\n' +
                    '    <li>Player player (#42) <i></i></li>\n' +
                    '</ul>\n' +
                    ' \n' +
                    '\n' +
                    '<p>To disable these emails, update your user settings to turn off email for updates.</p>\n' +
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
                from: 'noreply@email.teamsfuse.com',
                to: 'test@test.com',
                attachments: mailAttachments,
            });
        } finally {
            cache.close();
        }
    });

    it('notify - works', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        await createPlayer(['me', 'other'], 'player');
        await createUser(['1234'], 'me');

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await emailForGame(
                gameDoc,
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                cache,
                new ChangedData(),
            );
            spy.should.have.been.callCount(1);
            spy.getCall(0).should.have.been.calledWith({
                subject: '[Lookup TeamName] Game at  vs Test Opponent',
                text:
                    'Reminder for upcoming game with Lookup TeamName, details below:\n' +
                    '\n' +
                    'Arrive At   : Friday, May 25, 2018, 5:00 AM Pacific Daylight Time\n' +
                    'Start Time  : \n' +
                    'Address     : 1502 west test drive\n' +
                    'PlaceName   : Test High School\n' +
                    'PlaceNotes  : \n' +
                    'Uniform     : white/red/black\n' +
                    'Notes       : Do not drive backwards\n' +
                    '\n' +
                    'Availability\n' +
                    '  No one is going\n' +
                    '\n' +
                    '\n' +
                    'MAYBE\n' +
                    '  Player player (#42) \n' +
                    '\n' +
                    'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                    '\n' +
                    'Map: https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined\n' +
                    '\n' +
                    `https://www.teamsfuse.com/main/Game/View/${seasonDocId}/${gameDoc.id}\n` +
                    '\n' +
                    '-----\n' +
                    'TeamsFuse is an app to help organize your sports teams.\n' +
                    'https://www.teamsfuse.com\n' +
                    '\n' +
                    'iPhone download: https://apps.apple.com/us/app/team-fuse/id1374615208\n' +
                    'Android download: https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse\n',
                html:
                    'Reminder for upcoming game with <b><a href="https://www.teamsfuse.com/main/Team/View/' +
                    teamDocId +
                    '">Lookup TeamName</a></b>, details below:\n' +
                    '\n' +
                    '<img src="cid:teamimg" width="100" height="100" />\n' +
                    '\n' +
                    '<h4><a href="https://www.teamsfuse.com/main/Game/View/' +
                    seasonDocId +
                    '/' +
                    gameDoc.id +
                    '">Details</a></h4>\n' +
                    '<table>\n' +
                    '    <tr>\n' +
                    '        <td>Arrive At</td>\n' +
                    '        <td>Friday, May 25, 2018, 5:00 AM Pacific Daylight Time</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Start Time</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Address</td>\n' +
                    '        <td>\n' +
                    '            <a href="https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined">1502 west test drive</a>\n' +
                    '        </td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Name</td>\n' +
                    '        <td>Test High School</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Notes</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Uniform</td>\n' +
                    '        <td>white/red/black</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Notes</td>\n' +
                    '        <td>Do not drive backwards</td>\n' +
                    '    </tr>\n' +
                    '</table>\n' +
                    '\n' +
                    '<h4>Availability</h4>\n' +
                    ' <b>No one is going</b>\n' +
                    '  \n' +
                    '<b>Maybe</b>\n' +
                    '<ul>\n' +
                    '    <li>Player player (#42) <i></i></li>\n' +
                    '</ul>\n' +
                    ' \n' +
                    '\n' +
                    '<p>To disable these emails, update your user settings to turn off email for updates.</p>\n' +
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
                from: 'noreply@email.teamsfuse.com',
                to: 'test@test.com',
                attachments: mailAttachments,
            });
        } finally {
            cache.close();
        }
    });

    it('notify - availability', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        await createPlayer(['me'], 'player');
        await createPlayer(['other'], 'womble');
        await createPlayer(['me'], 'frog');
        await createPlayer(['me'], 'tadpole');
        await createUser(['1234'], 'me');
        await createUser(['123456'], 'other');

        // Update the season to add in all the players.emailUpcoming
        await admin
            .firestore()
            .collection('Seasons')
            .doc(seasonDocId)
            .update({
                'players.womble': {
                    other: true,
                    added: true,
                    public: false,
                    jerseyNumber: '00',
                    playerUid: 'womble',
                    role: 'Player',
                },
                'players.frog': {
                    me: true,
                    added: true,
                    public: false,
                    jerseyNumber: '12',
                    playerUid: 'frog',
                    role: 'Player',
                },
                'players.tadpole': {
                    me: true,
                    added: true,
                    public: false,
                    jerseyNumber: '24',
                    playerUid: 'tadpole',
                    role: 'Player',
                },
            });
        // Update the game to add in availability.
        await admin
            .firestore()
            .collection('Games')
            .doc(gameDoc.id)
            .update({
                attendance: {
                    frog: 'Yes',
                    tadpole: 'Yes',
                    womble: 'No',
                    player: 'Maybe',
                },
            });

        // Just make sure creating a club actually works.
        const cache = new DataNodeCache();
        try {
            await emailForGame(
                await gameDoc.ref.get(),
                {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                },
                '',
                'emailUpcoming',
                cache,
                new ChangedData(),
            );
            spy.should.have.been.callCount(4);
            spy.getCall(0).should.have.been.calledWith({
                subject: '[Lookup TeamName] Game at  vs Test Opponent',
                text:
                    'Reminder for upcoming game with Lookup TeamName, details below:\n' +
                    '\n' +
                    'Arrive At   : Friday, May 25, 2018, 5:00 AM Pacific Daylight Time\n' +
                    'Start Time  : \n' +
                    'Address     : 1502 west test drive\n' +
                    'PlaceName   : Test High School\n' +
                    'PlaceNotes  : \n' +
                    'Uniform     : white/red/black\n' +
                    'Notes       : Do not drive backwards\n' +
                    '\n' +
                    'Availability\n' +
                    'YES\n' +
                    '  Player frog (#12) \n' +
                    '  Player tadpole (#24) \n' +
                    '\n' +
                    'NO\n' +
                    '  Player womble (#00) \n' +
                    '\n' +
                    'MAYBE\n' +
                    '  Player player (#42) \n' +
                    '\n' +
                    'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                    '\n' +
                    'Map: https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined\n' +
                    '\n' +
                    `https://www.teamsfuse.com/main/Game/View/${seasonDocId}/${gameDoc.id}\n` +
                    '\n' +
                    '-----\n' +
                    'TeamsFuse is an app to help organize your sports teams.\n' +
                    'https://www.teamsfuse.com\n' +
                    '\n' +
                    'iPhone download: https://apps.apple.com/us/app/team-fuse/id1374615208\n' +
                    'Android download: https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse\n',
                html:
                    'Reminder for upcoming game with <b><a href="https://www.teamsfuse.com/main/Team/View/' +
                    teamDocId +
                    '">Lookup TeamName</a></b>, details below:\n' +
                    '\n' +
                    '<img src="cid:teamimg" width="100" height="100" />\n' +
                    '\n' +
                    '<h4><a href="https://www.teamsfuse.com/main/Game/View/' +
                    seasonDocId +
                    '/' +
                    gameDoc.id +
                    '">Details</a></h4>\n' +
                    '<table>\n' +
                    '    <tr>\n' +
                    '        <td>Arrive At</td>\n' +
                    '        <td>Friday, May 25, 2018, 5:00 AM Pacific Daylight Time</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Start Time</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Address</td>\n' +
                    '        <td>\n' +
                    '            <a href="https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined">1502 west test drive</a>\n' +
                    '        </td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Name</td>\n' +
                    '        <td>Test High School</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Place Notes</td>\n' +
                    '        <td></td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Uniform</td>\n' +
                    '        <td>white/red/black</td>\n' +
                    '    </tr>\n' +
                    '    <tr>\n' +
                    '        <td>Notes</td>\n' +
                    '        <td>Do not drive backwards</td>\n' +
                    '    </tr>\n' +
                    '</table>\n' +
                    '\n' +
                    '<h4>Availability</h4>\n' +
                    ' \n' +
                    '<b>Yes</b>\n' +
                    '<ul>\n' +
                    '    <li>Player frog (#12) <i></i></li>\n' +
                    '    <li>Player tadpole (#24) <i></i></li>\n' +
                    '</ul>\n' +
                    ' \n' +
                    '<b>No</b>\n' +
                    '<ul>\n' +
                    '    <li>Player womble (#00) <i></i></li>\n' +
                    '</ul>\n' +
                    ' \n' +
                    '<b>Maybe</b>\n' +
                    '<ul>\n' +
                    '    <li>Player player (#42) <i></i></li>\n' +
                    '</ul>\n' +
                    ' \n' +
                    '\n' +
                    '<p>To disable these emails, update your user settings to turn off email for updates.</p>\n' +
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
                from: 'noreply@email.teamsfuse.com',
                to: 'test@test.com',
                attachments: mailAttachments,
            });
        } finally {
            cache.close();
        }
    });
});
