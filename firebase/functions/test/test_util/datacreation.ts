import * as admin from 'firebase-admin';
import { v4 as uuid } from 'uuid';
import { DocumentSnapshot } from '@google-cloud/firestore';
import { DateTime } from 'luxon';

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
                    me: {
                        added: true,
                        admin: true,
                    },
                },
                users: {
                    me: {
                        added: true,
                        admin: true,
                    },
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
                    me: { added: true, admin: true },
                },
                users: {
                    me: {
                        added: true,
                        admin: true,
                    },
                },
            });
    }
    await admin
        .firestore()
        .collection('Seasons')
        .doc(seasonDocId)
        .set({
            name: 'Current Season',
            uid: seasonDocId,
            teamUid: teamDocId,
            isPublic: isPublicVisibleSeason,
            users: {
                me: {
                    added: true,
                    admin: true,
                },
            },
            players: {
                player: {
                    me: true,
                    added: true,
                    public: false,
                    jerseyNumber: '42',
                    playerUid: 'player',
                    role: 'Player',
                },
            },
        });

    return {
        team: await admin.firestore().collection('Teams').doc(teamDocId).get(),
        season: await admin.firestore().collection('Seasons').doc(seasonDocId).get(),
    };
}

export async function createPlayer(users: string[], uid?: string, isPublic?: boolean): Promise<DocumentSnapshot> {
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
            playerType: 'player',
            isPublic: isPublic ?? false,
        });
    return await admin.firestore().collection('Players').doc(playerDocId).get();
}

export async function createUser(
    tokens: string[],
    uid?: string,
    emailUpcoming?: boolean,
    emailOnUpdates?: boolean,
): Promise<DocumentSnapshot> {
    const userDocId = uid ?? uuid();
    const tokenData: Record<string, boolean> = {};
    const emailUpcomingReal = emailUpcoming ?? true;
    const emailOnUpdatesReal = emailOnUpdates ?? true;
    for (const idx in tokens) {
        const t = tokens[idx];
        tokenData[t] = true;
    }

    await admin
        .firestore()
        .collection('UserData')
        .doc(userDocId)
        .set({
            displayName: 'User ' + userDocId,
            uid: userDocId,
            emailOnUpdates: emailOnUpdatesReal,
            emailUpcoming: emailUpcomingReal,
            phone: '425-339-1234',
            email: 'test@test.com',
            tokens: tokenData,
        });
    return await admin.firestore().collection('UserData').doc(userDocId).get();
}

export async function createClub(members = ['member'], admins = ['waffles'], uid?: string): Promise<DocumentSnapshot> {
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

export async function createOpponent(teamUid: string, name?: string): Promise<DocumentSnapshot> {
    const opponentUid = uuid();

    await admin
        .firestore()
        .collection('Teams')
        .doc(teamUid)
        .collection('Opponents')
        .doc(opponentUid)
        .set({
            teamUid: teamUid,
            uid: opponentUid,
            name: name ?? 'Test Opponent',
        });

    return admin.firestore().collection('Teams').doc(teamUid).collection('Opponents').doc(opponentUid).get();
}

export async function createGame(
    teamUid: string,
    seasonUid: string,
    arriveTime: DateTime,
    opponentUid: string,
    name?: string,
): Promise<DocumentSnapshot> {
    const gameDocId = uuid();
    const sharedGameDocId = uuid();

    const sharedData = {
        name: name ?? 'Game',
        place: {
            address: '1502 west test drive',
            name: 'Test High School',
            lat: 12,
            long: 34,
        },
        uid: sharedGameDocId,
        time: arriveTime.valueOf(),
        endTime: arriveTime.valueOf(),
        type: 'Game',
        timezone: 'America/Los_Angeles',
        officialResult: {
            result: 'Unknown',
            scores: {},
        },
    };

    await admin.firestore().collection('GamesShared').doc(sharedGameDocId).set(sharedData);

    await admin
        .firestore()
        .collection('Games')
        .doc(gameDocId)
        .set({
            name: name ?? 'Game',
            uid: gameDocId,
            teamUid: teamUid,
            seasonUid: seasonUid,
            sharedDataUid: sharedGameDocId,
            sharedData: sharedData,
            notes: 'Do not drive backwards',
            uniform: 'white/red/black',
            endTime: arriveTime.valueOf() + 3000,
            arrivalTime: arriveTime.valueOf(),
            opponentUid: opponentUid,
            result: {
                result: 'Unknown',
                inProgress: 'NotStarted',
                currentPeriod: 'NotStarted--0',
                divisions: 'Quarters',
                scores: {},
            },
            // Empty, no data for the player for this game.
            players: {},
        });

    return admin.firestore().collection('Games').doc(gameDocId).get();
}
