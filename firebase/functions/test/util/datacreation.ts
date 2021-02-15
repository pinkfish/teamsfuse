import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';
import { DocumentSnapshot } from '@google-cloud/firestore';

interface TeamAndSeason {
    team: DocumentSnapshot;
    season: DocumentSnapshot;
}

export async function createSeason(isPublicVisibleSeason: boolean, teamUid: string): Promise<DocumentSnapshot> {
    const seasonDocId = uuid();

    await admin.firestore().collection('Seasons').doc(seasonDocId).set({
        name: 'Current Season',
        uid: seasonDocId,
        teamUid: teamUid,
        isPublic: isPublicVisibleSeason,
    });

    return admin.firestore().collection('Seasons').doc(seasonDocId).get();
}

export async function createSeasonAndTeam(
    isPublicVisibleSeason: boolean,
    isPublicVisibleTeam: boolean,
    clubUid?: string,
): Promise<TeamAndSeason> {
    const seasonDocId = uuid();
    const teamDocId = uuid();

    // Setup some data to be queried first.
    if (clubUid !== undefined) {
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
                clubUid: clubUid,
                admins: {
                    me: true,
                },
            });
    } else {
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
    }
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

export async function createPlayer(users: string[], uid?: string): Promise<DocumentSnapshot> {
    const playerDocId = uid ?? uuid();
    const userData: Record<string, any> = {};
    for (const idx in users) {
        const u = users[idx];
        userData[u] = {
            added: true,
            relationship: 'Parent',
        };
    }
    await admin
        .firestore()
        .collection('Players')
        .doc(playerDocId)
        .set({
            name: 'Player ' + playerDocId,
            uid: playerDocId,
            users: userData,
        });
    return await admin.firestore().collection('Players').doc(playerDocId).get();
}

export async function createClub(members = ['member'], admins = ['other'], uid?: string): Promise<DocumentSnapshot> {
    const clubDocId = uid ?? uuid();
    const userData: Record<string, any> = {};
    for (const idx in members) {
        const u = members[idx];
        userData[u] = {
            added: true,
            admin: false,
        };
    }
    for (const idx in admins) {
        const u = admins[idx];
        userData[u] = {
            added: true,
            admin: true,
        };
    }
    await admin
        .firestore()
        .collection('Clubs')
        .doc(clubDocId)
        .set({
            name: 'Club ' + clubDocId,
            uid: clubDocId,
            members: userData,
        });
    return await admin.firestore().collection('Clubs').doc(clubDocId).get();
}
