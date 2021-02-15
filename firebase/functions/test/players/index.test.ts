import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
import { expect } from 'chai';
import { createPlayer, createSeasonAndTeam } from '../util/datacreation';
import * as admin from 'firebase-admin';

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

import { onPlayerWrite } from '../../ts/db/player/update.f';

describe('Player Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('create with a user, no teams', async () => {
        // Just make sure creating a player actually works.
        const player = await createPlayer(['me']);
        const playerDocId = player.id;
        const oldPlayer = test.firestore.makeDocumentSnapshot({}, 'Players/' + playerDocId);
        await test.wrap(onPlayerWrite)(test.makeChange(oldPlayer, player), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const playerDoc = await player.ref.get();
        const data = playerDoc;
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(playerDocId);
            }
        }
    });

    it('update add user, in a team', async () => {
        // Just make sure creating a player actually works.
        const player = await createPlayer(['me', 'other'], 'player');
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const playerDocId = player.id;
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;

        // Add the player to the team.
        await teamAndSeason.season.ref.update('players.player.added', true);
        await teamAndSeason.season.ref.update('players.player.me', true);

        const oldData = player.data()!;
        oldData['users'] = {};

        const oldPlayer = test.firestore.makeDocumentSnapshot(oldData, 'Players/' + playerDocId);
        await test.wrap(onPlayerWrite)(test.makeChange(oldPlayer, player), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = player;
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(playerDocId);
            }
        }
        const seasonData = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
        if (seasonData !== null && seasonData !== undefined) {
            expect(seasonData.exists).to.be.true;
            const myData = seasonData.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.users).to.deep.equal({
                    me: {
                        added: true,
                        admin: true,
                        player: true,
                    },
                    other: {
                        added: true,
                        player: true,
                    },
                });
                expect(myData.players).to.deep.equal({
                    player: {
                        added: true,
                        me: true,
                        other: true,
                    },
                });
            }
        }
        const teamData = await admin.firestore().collection('Teams').doc(teamDocId).get();
        if (teamData !== null && teamData !== undefined) {
            expect(teamData.exists).to.be.true;
            const myData = teamData.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.users).to.deep.equal({
                    me: {
                        added: true,
                        admin: true,
                        player: true,
                    },
                    other: {
                        added: true,
                        player: true,
                    },
                });
            }
        }
    });

    it('update remove user, in a team', async () => {
        // Just make sure creating a player actually works.
        const player = await createPlayer(['me', 'other'], 'player');
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const playerDocId = player.id;
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;

        // Add the player to the team.
        await teamAndSeason.season.ref.update('players.player', { added: true, me: true, other: true });
        await teamAndSeason.season.ref.update('users', {
            me: { added: true, player: true },
            other: { added: true, player: true },
        });
        await teamAndSeason.team.ref.update('players.player', { added: true, me: true, other: true });
        await teamAndSeason.team.ref.update('users', {
            me: { added: true, player: true },
            other: { added: true, player: true },
        });

        const newPlayerData = player.data()!;
        newPlayerData['users'] = {
            me: {
                added: true,
                relationship: 'Parent',
            },
        };

        const newPlayer = test.firestore.makeDocumentSnapshot(newPlayerData, 'Players/' + playerDocId);
        await test.wrap(onPlayerWrite)(test.makeChange(player, newPlayer), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = player;
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(playerDocId);
            }
        }
        const seasonData = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
        if (seasonData !== null && seasonData !== undefined) {
            expect(seasonData.exists).to.be.true;
            const myData = seasonData.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.users).to.deep.equal({
                    me: {
                        added: true,
                        player: true,
                    },
                });
                expect(myData.players).to.deep.equal({
                    player: {
                        added: true,
                        me: true,
                    },
                });
            }
        }
        const teamData = await admin.firestore().collection('Teams').doc(teamDocId).get();
        if (teamData !== null && teamData !== undefined) {
            expect(teamData.exists).to.be.true;
            const myData = teamData.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.users).to.deep.equal({
                    me: {
                        added: true,
                        player: true,
                    },
                });
            }
        }
    });
});
