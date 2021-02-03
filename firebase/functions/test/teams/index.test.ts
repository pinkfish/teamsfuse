import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
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

import { onTeamUpdate } from '../../ts/db/team/update.f';

interface TeamAndSeason {
    team: DocumentSnapshot;
    season: DocumentSnapshot;
}

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

    async function createSeason(isPublicVisibleSeason: boolean, teamUid: string): Promise<DocumentSnapshot> {
        const seasonDocId = uuid();

        await admin.firestore().collection('Seasons').doc(seasonDocId).set({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamUid,
            isPublic: isPublicVisibleSeason,
        });

        return admin.firestore().collection('Seasons').doc(seasonDocId).get();
    }

    async function createSeasonAndTeam(
        isPublicVisibleSeason: boolean,
        isPublicVisibleTeam: boolean,
    ): Promise<TeamAndSeason> {
        const seasonDocId = uuid();
        const teamDocId = uuid();

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
                isPublic: isPublicVisibleTeam,
                admins: {
                    me: true,
                },
            });
        await admin.firestore().collection('Seasons').doc(seasonDocId).set({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamDocId,
            isPublic: isPublicVisibleSeason,
        });

        return {
            team: await admin.firestore().collection('Teams').doc(teamDocId).get(),
            season: await admin.firestore().collection('Seasons').doc(seasonDocId).get(),
        };
    }

    it('keeps players correct', async () => {
        return;
    }).timeout(10000);

        it('keeps admins correct', async () => {
            return;
        }).timeout(10000);

});
