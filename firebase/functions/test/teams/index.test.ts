import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
import { expect } from 'chai';
import * as admin from 'firebase-admin';
import { DocumentSnapshot } from '@google-cloud/firestore';
import { createSeasonAndTeam, createSeason, createClub } from '../util/datacreation';

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

import { onTeamUpdate } from '../../ts/db/team/update.f';
import { onTeamCreate } from '../../ts/db/team/create.f';

describe('Teams Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('basic team update no change', async () => {
        await publicTeamTest(false, false, false, false);
        return;
    }).timeout(10000);

    it('public team no change (both public)', async () => {
        await publicTeamTest(false, true, true, false);
        return;
    }).timeout(10000);

    it('public team public to private', async () => {
        await publicTeamTest(false, false, true, false);
        return;
    }).timeout(10000);

    it('public team private to public', async () => {
        await publicTeamTest(false, true, false, false);
        return;
    }).timeout(10000);

    async function publicTeamTest(
        isPublicVisibleSeason: boolean,
        isPublicVisibleTeam: boolean,
        isPublicVisibleTeamOld: boolean,
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
            // Make fake old data.
            const oldTeam = test.firestore.makeDocumentSnapshot(
                {
                    name: 'Lookup TeamName',
                    photourl: null,
                    currentSeason: seasonDocId,
                    uid: teamDocId,
                    isPublic: isPublicVisibleTeamOld,
                    admins: {
                        me: true,
                    },
                },
                'Teams/' + teamDocId,
            );
            await test.wrap(onTeamUpdate)(test.makeChange(oldTeam, teamAndSeason.team), {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            const data = await admin.firestore().collection('Teams').doc(teamDocId).get();
            expect(data).to.not.be.null;
            if (data !== null && data !== undefined) {
                expect(data.exists).to.be.true;
                const myData = data.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.uid).to.equal(teamDocId);
                    expect(myData.currentSeason).to.equal(seasonDocId);
                    expect(myData.isPublic).to.equal(isPublicVisibleTeam);
                }
            }

            const seasonDocUpdate = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            expect(seasonDocUpdate).to.not.be.null;
            if (seasonDocUpdate !== null && seasonDocUpdate !== undefined) {
                expect(seasonDocUpdate.exists).to.be.true;
                const myData = seasonDocUpdate.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.uid).to.equal(seasonDocId);
                    expect(myData.teamUid).to.equal(teamDocId);
                    expect(myData.isPublic).to.equal(
                        isPublicVisibleTeam === isPublicVisibleTeamOld ? isPublicVisibleSeason : isPublicVisibleTeam,
                    );
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

    it('keeps players correct', async () => {
        const stuff = await createSeasonAndTeam(false, false);
        const teamDocId = stuff.team.id;
        const seasonDocId = stuff.season.id;
        // Make fake new data.
        const newTeam = test.firestore.makeDocumentSnapshot(
            {
                name: 'Lookup TeamName',
                photourl: null,
                currentSeason: seasonDocId,
                uid: teamDocId,
                isPublic: false,
                players: {
                    woggle: {
                        playerUid: 'waffle',
                    },
                },
            },
            'Teams/' + teamDocId,
        );

        try {
            await test.wrap(onTeamUpdate)(test.makeChange(newTeam, stuff.team), {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            throw e;
        }

        return;
    }).timeout(10000);

    it('keeps admins correct', async () => {
        return;
    }).timeout(10000);

    it('create with club', async () => {
        const club = await createClub();
        const clubDocId = club.id;
        const stuff = await createSeasonAndTeam(false, false, clubDocId);
        const teamDocId = stuff.team.id;
        const seasonDocId = stuff.season.id;
        try {
            console.log('Creating');
            await test.wrap(onTeamCreate)(stuff.team, {
                auth: {
                    uid: 'me',
                },
                authType: 'USER',
            });

            // Verify the users are updated (team).
            const data = await admin.firestore().collection('Teams').doc(teamDocId).get();
            expect(data).to.not.be.null;
            if (data !== null && data !== undefined) {
                expect(data.exists).to.be.true;
                const myData = data.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.uid).to.equal(teamDocId);
                    expect(myData.users).to.deep.equal({
                        other: {
                            club: true,
                            added: true,
                        },
                        member: {
                            club: true,
                            added: true,
                        },
                    });
                    expect(myData.admins).to.deep.equal({
                        me: true,
                        other: true,
                    });
                }
            }

            // Verify the users are updated (seaspn).
            const seasonData = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
            expect(seasonData).to.not.be.null;
            if (seasonData !== null && seasonData !== undefined) {
                expect(seasonData.exists).to.be.true;
                const myData = seasonData.data();
                expect(myData).to.not.be.null;
                if (myData !== undefined && myData !== null) {
                    expect(myData.uid).to.equal(seasonDocId);
                    expect(myData.users).to.deep.equal({
                        other: {
                            club: true,
                            added: true,
                        },
                        member: {
                            club: true,
                            added: true,
                        },
                    });
                }
            }

            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Clubs').doc(clubDocId).delete();
        } catch (e) {
            console.log(e);
            console.log(e.stack);
            await admin.firestore().collection('Seasons').doc(seasonDocId).delete();
            await admin.firestore().collection('Teams').doc(teamDocId).delete();
            await admin.firestore().collection('Clubs').doc(clubDocId).delete();
            throw e;
        }

        return;
    }).timeout(10000);
});
