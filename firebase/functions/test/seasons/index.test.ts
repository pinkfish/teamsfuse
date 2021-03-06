import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';
import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createSeason } from '../util/datacreation';

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

import { onSeasonCreate } from '../../ts/db/season/create.f';
import { onSeasonUpdate } from '../../ts/db/season/update.f';

describe('Seasons Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('basic season create', async () => {
        await publicTeamTest(false, false, false);
        return;
    }).timeout(10000);

    it('public season create public, team private', async () => {
        await publicTeamTest(true, false, false);
        return;
    }).timeout(10000);

    it('public season create public, team public', async () => {
        await publicTeamTest(true, true, true);
        return;
    }).timeout(10000);

    it('public season create private, team public', async () => {
        await publicTeamTest(false, true, true);
        return;
    }).timeout(10000);

    it('public season create private, team public extra', async () => {
        await publicTeamTest(false, true, true, [true, true, false, true]);
        return;
    }).timeout(10000);

    async function publicTeamTest(
        isPublicVisibleSeason: boolean,
        isPublicVisibleTeam: boolean,
        seasonResult: boolean,
        extra: boolean[] = [],
    ): Promise<void> {
        const teamAndSeason = await createSeasonAndTeam(isPublicVisibleSeason, isPublicVisibleTeam);
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        const newSeasons: DocumentSnapshot[] = await Promise.all(
            extra.map(async (v) => await createSeason(v, teamDocId)),
        );
        try {
            await test.wrap(onSeasonCreate)(teamAndSeason.season, {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            const data = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            expect(data).to.not.be.null;
            if (data !== null && data !== undefined) {
                expect(data.exists).to.be.true;
                const myData = data.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.teamUid).to.equal(teamDocId);
                    expect(myData.uid).to.equal(seasonDocId);
                    expect(myData.isPublic).to.equal(seasonResult);
                }
            }
            for (const doc in newSeasons) {
                const extraSeasonGet = await newSeasons[doc].ref.get();
                expect(extraSeasonGet.exists).to.be.true;
                const extraData = extraSeasonGet.data();
                expect(extraData).to.not.be.null;
                if (extraData !== undefined && extraData !== null) {
                    expect(extraData.teamUid).to.equal(teamDocId);
                    expect(extraData.isPublic).to.equal(false);
                }
            }
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            for (const doc in newSeasons) {
                await newSeasons[doc].ref.delete();
            }
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            for (const doc in newSeasons) {
                await newSeasons[doc].ref.delete();
            }
            throw e;
        }
        return;
    }

    // Validate it fills in the users correctly when the season is created.
    it('season, fix users - create', async () => {
        const seasonDocId = uuid();
        const teamDocId = uuid();
        const playerDocId = uuid();

        await admin
            .firestore()
            .collection('Players')
            .doc(playerDocId)
            .set({
                user: {
                    me: {
                        added: true,
                        relationship: 'Parent',
                    },
                },
            });

        // Setup some data to be queried first.
        await admin
            .firestore()
            .collection('Teams')
            .doc(teamDocId)
            .set({
                name: 'Lookup TeamName',
                photourl: null,
                currentSeason: seasonDocId,
                uid: teamDocId,
                isPublic: true,
                admins: {
                    me: true,
                },
            });

        const playerStuff: { [key: string]: any } = {};
        playerStuff[playerDocId] = {
            added: true,
            name: 'frog',
        };
        await admin.firestore().collection('Seasons').doc(seasonDocId).set({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamDocId,
            isPublic: true,
            players: playerStuff,
        });

        try {
            await test.wrap(onSeasonCreate)(await admin.firestore().collection('Seasons').doc(seasonDocId).get(), {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            const data = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            expect(data).to.not.be.null;
            if (data !== null && data !== undefined) {
                expect(data.exists).to.be.true;
                const myData = data.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.teamUid).to.equal(teamDocId);
                    const playerCheck: { [key: string]: boolean } = {};
                    playerCheck['added'] = true;
                    playerCheck[playerDocId] = true;
                    expect(myData.users).to.be.an('object').that.deep.own.includes({
                        me: playerCheck,
                    });
                }
            }
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Players').doc(playerDocId).delete();
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Players').doc(playerDocId).delete();
            throw e;
        }
        return;
    });

    // Validate it fills in the users correctly when the season is created.
    it('season, fix users - update', async () => {
        const seasonDocId = uuid();
        const teamDocId = uuid();
        const playerDocId = uuid();

        await admin
            .firestore()
            .collection('Players')
            .doc(playerDocId)
            .set({
                user: {
                    me: {
                        added: true,
                        relationship: 'Parent',
                    },
                },
            });

        // Setup some data to be queried first.
        await admin
            .firestore()
            .collection('Teams')
            .doc(teamDocId)
            .set({
                name: 'Lookup TeamName',
                photourl: null,
                currentSeason: seasonDocId,
                uid: teamDocId,
                isPublic: true,
                admins: {
                    me: true,
                },
            });

        const playerStuff: { [key: string]: any } = {};
        playerStuff[playerDocId] = {
            added: true,
            name: 'frog',
        };
        await admin.firestore().collection('Seasons').doc(seasonDocId).set({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamDocId,
            isPublic: true,
            players: playerStuff,
        });

        try {
            const newSeason = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            await test.wrap(onSeasonUpdate)(test.makeChange(newSeason, newSeason), {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            const data = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            expect(data).to.not.be.null;
            if (data !== null && data !== undefined) {
                expect(data.exists).to.be.true;
                const myData = data.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.teamUid).to.equal(teamDocId);
                    const playerCheck: { [key: string]: boolean } = {};
                    playerCheck['added'] = true;
                    playerCheck[playerDocId] = true;
                    expect(myData.users).to.be.an('object').that.deep.own.includes({
                        me: playerCheck,
                    });
                }
            }
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Players').doc(playerDocId).delete();
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Players').doc(playerDocId).delete();
            throw e;
        }
        return;
    });
});
