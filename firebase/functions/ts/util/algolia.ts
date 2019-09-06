import * as algoliasearch from 'algoliasearch';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const algolia = algoliasearch(functions.config().algolia.appid, functions.config().algolia.key);
const teamIndex = algolia.initIndex('teams');
const db = admin.firestore();

export function updateTeam(teamDoc: functions.firestore.DocumentSnapshot): Promise<any> {
    const data = teamDoc!.data();
    if (data === null || data === undefined) {
        return Promise.resolve(null);
    }
    data.objectID = 'T' + teamDoc.id;
    delete data.archived;
    delete data.admins;
    delete data.currentSeason;
    delete data.trackAttendence;
    delete data.arrivalTime;
    delete data.arriveEarly;
    data.searchRanking = 1000;
    return teamIndex.saveObjects([data]);
}

export function deleteTeam(teamId: string): Promise<any> {
    return teamIndex.deleteObjects(['T' + teamId]);
}

export function updateLeagueTeam(teamDoc: functions.firestore.DocumentSnapshot): Promise<any> {
    const data = teamDoc.data();
    data!.objectID = 't' + teamDoc.id;
    delete data!.members;
    delete data!.record;
    data!.searchRanking = 500;
    // Update the data with fun.
    return db
        .collection('LeagueDivison')
        .doc(teamDoc.data()!.leagueDivisonUid)
        .get()
        .then((snap: functions.firestore.DocumentSnapshot) => {
            if (snap !== null && snap.exists) {
                const divisonData = snap.data();
                data!.leagueDivisonName = divisonData!.name;
                data!.leagueSeasonUid = divisonData!.seasonUid;
                return db
                    .collection('LeagueSeason')
                    .doc(divisonData!.seasonUid)
                    .get();
            }
            return null;
        })
        .then((snap: functions.firestore.DocumentSnapshot | null) => {
            if (snap !== null && snap.exists) {
                const seasonData = snap.data();
                data!.leagueSeasonName = seasonData!.name;
                data!.leagueUid = seasonData!.leagueUid;
                return db
                    .collection('League')
                    .doc(seasonData!.leagueUid)
                    .get();
            }
            return Promise.resolve(null);
        })
        .then((snap: functions.firestore.DocumentSnapshot | null) => {
            if (snap !== null && snap.exists) {
                const leagueData = snap.data();
                data!.leagueName = leagueData!.name;
            }
            return teamIndex.saveObjects([data!]);
        });
}

export function deleteLeagueTeam(teamId: string): Promise<any> {
    return teamIndex.deleteObjects(['t' + teamId]);
}

export function updateLeague(leagueDoc: functions.firestore.DocumentSnapshot): Promise<any> {
    const data = leagueDoc.data();
    data!.objectID = 'L' + leagueDoc.id;
    delete data!.members;
    delete data!.currentSeason;
    data!.searchRanking = 900;
    teamIndex.browse(
        '',
        {
            filters: 'leagueUid="' + leagueDoc.id + '"',
            attributesToRetrieve: ['leagueDivisonName '],
        },
        (err: Error, content: Record<string, any>) => {
            if (err) {
                throw err;
            }

            // Get the records to update.
            const toUpdateRecords = new Set();
            for (const i in content.hits) {
                const hit = content.hits[i];
                toUpdateRecords.add(hit.objectID);
            }
            const records: Record<string, any>[] = [];
            toUpdateRecords.forEach(id => {
                const pushData = { leagueDivisonName: leagueDoc!.data()!.name, objectID: id };
                records.push(pushData);
            });
            return teamIndex.partialUpdateObjects(records);
        },
    );
    return Promise.resolve(null);
}

export function deleteLeague(teamId: string): Promise<any> {
    return teamIndex.deleteObjects(['L' + teamId]);
}

export function updateLeagueSeason(teamDoc: functions.firestore.DocumentSnapshot): Promise<any> {
    teamIndex.browse(
        '',
        {
            filters: 'leagueSeasonUid="' + teamDoc.id + '"',
            attributesToRetrieve: ['leagueSeasonName '],
        },
        (err: Error, content: Record<string, any>) => {
            if (err) {
                throw err;
            }

            // Get the records to update.
            const toUpdateRecords = new Set();
            for (const i in content.hits) {
                const hit = content.hits[i];
                toUpdateRecords.add(hit.objectID);
            }
            const records: Record<string, any>[] = [];
            toUpdateRecords.forEach(id => {
                const data = { leagueSeasonName: teamDoc!.data()!.name, objectID: id };
                records.push(data);
            });
            return teamIndex.partialUpdateObjects(records);
        },
    );

    return Promise.resolve(null);
}

export function deleteLeagueSeason(teamId: string) {
    return;
}

export function updateLeagueDivison(teamDoc: functions.firestore.DocumentSnapshot): Promise<any> {
    teamIndex.browse(
        '',
        {
            filters: 'leagueDivisonUid="' + teamDoc.id + '"',
            attributesToRetrieve: ['leagueDivisonName '],
        },
        (err: Error, content: Record<string, any>) => {
            if (err) {
                throw err;
            }

            // Get the records to update.
            const toUpdateRecords = new Set();
            for (const i in content.hits) {
                const hit = content.hits[i];
                toUpdateRecords.add(hit.objectID);
            }
            const records: Record<string, any>[] = [];
            toUpdateRecords.forEach(id => {
                const data = { leagueDivisonName: teamDoc!.data()!.name, objectID: id };
                records.push(data);
            });
            return teamIndex.partialUpdateObjects(records);
        },
    );
    return Promise.resolve(null);
}

export function deleteLeagueDivison(teamId: string) {
    return;
}
