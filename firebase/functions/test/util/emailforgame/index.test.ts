import * as sinon from 'sinon';
import { firebaseTest } from '../../test_util/firebase';
//import { expect } from 'chai';
import * as admin from 'firebase-admin';
import {
    createSeasonAndTeam,
    createGame,
    createOpponent,
    createPlayer,
    createUser,
} from '../../test_util/datacreation';
//import * as functions from 'firebase-functions';
import { DateTime, Settings } from 'luxon';
import * as nodemailer from 'nodemailer';
import SMTPTransport from 'nodemailer/lib/smtp-transport';
import * as email from '../../../ts/util/email';
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

import { emailForGame, ChangedData } from '../../../ts/util/notifyforgame';
import * as mailgun from '../../../ts/util/mailgun';

describe('Email for games', () => {
    let spy: sinon.SinonStub<[mailOptions: nodemailer.SendMailOptions], Promise<SMTPTransport.SentMessageInfo>>;

    before(() => {
        spy = sinon.stub(mailgun, 'sendMail');

        Settings.now = () => new Date(2018, 4, 25, 12, 0).valueOf();
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
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
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
        }
    });

    it('notify - opt out', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        const playerDoc = await createPlayer(['me', 'other'], 'player');
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
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('UserData').doc(userDoc.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc.id).delete();
        }
    });

    it('notify - works', async () => {
        spy.reset();

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
            sinon.assert.calledWith(spy, {
                subject: '[Lookup TeamName] Game at  vs Test Opponent',
                text:
                    '\n' +
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
                    `http://www.teamsfuses.com/event/${teamDocId}/${gameDoc.id}\n` +
                    '\n' +
                    '---\n' +
                    'Sent by TeamsFuse http://www.teamsfuse.com\n',
                html:
                    '\n' +
                    'Reminder for upcoming game with <b>Lookup TeamName</b>, details below:\n' +
                    '\n' +
                    '<img src="" width=100 height=100>\n' +
                    '\n' +
                    `<h4><a href="http://www.teamsfuses.com/event/${teamDocId}/${gameDoc.id}">Details</a></h4>\n` +
                    '<table>\n' +
                    '<tr>\n' +
                    '<td>Arrive At</td><td>Friday, May 25, 2018, 5:00 AM Pacific Daylight Time</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Start Time</td><td></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Address</td><td><a href="https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined">1502 west test drive</a></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Place Name</td><td>Test High School</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Place Notes</td><td></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Uniform</td><td>white/red/black</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Notes</td><td>Do not drive backwards</td>\n' +
                    '</tr>\n' +
                    '</table>\n' +
                    '\n' +
                    '<h4>Availability</h4>\n' +
                    '<b>No one is going</b>\n' +
                    '<b>Maybe</b>\n' +
                    '</ol>\n' +
                    '<li>Player player (#42) <i></i>\n' +
                    '</ol>\n' +
                    '\n' +
                    '<p>\n' +
                    'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                    '<p>\n' +
                    'Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>\n',
                from: 'noreply@email.teamsfuse.com',
                to: 'test@test.com',
            });
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

    it('notify - availability', async () => {
        spy.reset();

        const teamAndSeason = await createSeasonAndTeam(false, false);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const opponent = await createOpponent(teamDocId);
        const gameDoc = await createGame(teamDocId, seasonDocId, DateTime.now().toUTC(), opponent.id, 'Froggy');
        const playerDoc = await createPlayer(['me'], 'player');
        const playerDoc2 = await createPlayer(['other'], 'womble');
        const playerDoc3 = await createPlayer(['me'], 'frog');
        const playerDoc4 = await createPlayer(['me'], 'tadpole');
        const userDoc = await createUser(['1234'], 'me');
        const userDoc2 = await createUser(['123456'], 'other');

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
            sinon.assert.calledWith(spy, {
                subject: '[Lookup TeamName] Game at  vs Test Opponent',
                text:
                    '\n' +
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
                    `http://www.teamsfuses.com/event/${teamDocId}/${gameDoc.id}\n` +
                    '\n' +
                    '---\n' +
                    'Sent by TeamsFuse http://www.teamsfuse.com\n',
                html:
                    '\n' +
                    'Reminder for upcoming game with <b>Lookup TeamName</b>, details below:\n' +
                    '\n' +
                    '<img src="" width=100 height=100>\n' +
                    '\n' +
                    `<h4><a href="http://www.teamsfuses.com/event/${teamDocId}/${gameDoc.id}">Details</a></h4>\n` +
                    '<table>\n' +
                    '<tr>\n' +
                    '<td>Arrive At</td><td>Friday, May 25, 2018, 5:00 AM Pacific Daylight Time</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Start Time</td><td></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Address</td><td><a href="https://www.google.com/maps/dir/?api&#x3D;1&amp;destination&#x3D;1502%20west%20test%20drive&amp;destination_place_id&#x3D;undefined">1502 west test drive</a></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Place Name</td><td>Test High School</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Place Notes</td><td></td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Uniform</td><td>white/red/black</td>\n' +
                    '</tr>\n' +
                    '<tr>\n' +
                    '<td>Notes</td><td>Do not drive backwards</td>\n' +
                    '</tr>\n' +
                    '</table>\n' +
                    '\n' +
                    '<h4>Availability</h4>\n' +
                    '<b>Yes</b>\n' +
                    '<ul>\n' +
                    '<li>Player frog (#12) <i></i>\n' +
                    '<li>Player tadpole (#24) <i></i>\n' +
                    '</ul>\n' +
                    '<b>No</b>\n' +
                    '<ul>\n' +
                    '<li>Player womble (#00) <i></i>\n' +
                    '<b>Maybe</b>\n' +
                    '</ol>\n' +
                    '<li>Player player (#42) <i></i>\n' +
                    '</ol>\n' +
                    '\n' +
                    '<p>\n' +
                    'To disable these emails, update your user settings to turn off email for upcoming games.\n' +
                    '<p>\n' +
                    'Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>\n',
                from: 'noreply@email.teamsfuse.com',
                to: 'test@test.com',
            });
        } finally {
            cache.close();
            await admin.firestore().collection('Games').doc(gameDoc.id).delete();
            await admin.firestore().collection('Opponents').doc(opponent.id).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('UserData').doc(userDoc.id).delete();
            await admin.firestore().collection('UserData').doc(userDoc2.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc2.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc3.id).delete();
            await admin.firestore().collection('Players').doc(playerDoc4.id).delete();
        }
    });
});
