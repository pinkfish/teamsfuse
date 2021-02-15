import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
import { expect } from 'chai';
import { createClub, createSeasonAndTeam } from '../util/datacreation';
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

import { onClubWrite } from '../../ts/db/club/update.f';

describe('Club Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('create with a member, no teams', async () => {
        // Just make sure creating a club actually works.
        const club = await createClub(['me']);
        const clubDocId = club.id;
        const oldClub = test.firestore.makeDocumentSnapshot({}, 'Clubs/' + clubDocId);
        await test.wrap(onClubWrite)(test.makeChange(oldClub, club), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = await club.ref.get();
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(clubDocId);
            }
        }
    });

    it('update add user, in a team', async () => {
        // Just make sure creating a club actually works.
        const club = await createClub(['me', 'other'], ['fluff'], 'club');
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const clubDocId = club.id;
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;
        // Put the club on the team
        await admin.firestore().collection('Teams').doc(teamDocId).update({
            clubUid: clubDocId,
        });

        const oldData = club.data()!;
        oldData['members'] = {};

        const oldClub = test.firestore.makeDocumentSnapshot(oldData, 'Clubs/' + clubDocId);
        await test.wrap(onClubWrite)(test.makeChange(oldClub, club), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = await club.ref.get();
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(clubDocId);
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
                        club: true,
                    },
                    other: {
                        added: true,
                        club: true,
                    },
                    fluff: {
                        added: true,
                        club: true,
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
                        club: true,
                    },
                    other: {
                        added: true,
                        club: true,
                    },
                    fluff: {
                        added: true,
                        club: true,
                    },
                });
                expect(myData.admins).to.deep.equal({
                    fluff: { added: true, club: true },
                    me: { added: true, admin: true },
                });
            }
        }
    });

    it('update remove user, in a team', async () => {
        // Just make sure creating a cub actually works.
        const club = await createClub(['me', 'other'], ['fluff'], 'club');
        const teamAndSeason = await createSeasonAndTeam(false, false);
        const clubDocId = club.id;
        const teamDocId = teamAndSeason.team.id;
        const seasonDocId = teamAndSeason.season.id;

        // Add the club to the team.
        await admin.firestore().collection('Teams').doc(teamDocId).update({
            clubUid: clubDocId,
        });
        // Add in existing users.
        await teamAndSeason.season.ref.update('users', {
            me: { added: true, club: true },
            fluff: { added: true, club: true },
        });
        await teamAndSeason.team.ref.update('users', {
            me: { added: true, club: true },
            fluff: { added: true, club: true },
        });

        const newClubData = club.data()!;
        newClubData['members'] = {
            fluff: {
                added: true,
                admin: true,
            },
        };

        const newClub = test.firestore.makeDocumentSnapshot(newClubData, 'Clubs/' + clubDocId);
        await test.wrap(onClubWrite)(test.makeChange(club, newClub), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = await club.ref.get();

        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(clubDocId);
            }
        }
        const seasonData = await admin.firestore().collection('Seasons').doc(seasonDocId).get();
        if (seasonData !== null && seasonData !== undefined) {
            expect(seasonData.exists).to.be.true;
            const myData = seasonData.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.users).to.deep.equal({
                    fluff: {
                        added: true,
                        club: true,
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
                    fluff: {
                        added: true,
                        club: true,
                    },
                });
            }
        }
    });
});
