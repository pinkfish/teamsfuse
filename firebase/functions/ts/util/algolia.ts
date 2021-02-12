import algoliasearchType from 'algoliasearch';
import { ObjectWithObjectID } from '@algolia/client-search';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const algoliasearch: typeof algoliasearchType = require('algoliasearch');

const algolia = algoliasearch(functions.config().algolia.appid, functions.config().algolia.key);
const teamIndex = algolia.initIndex('teams');
const db = admin.firestore();

export async function updateTeam(teamDoc: functions.firestore.DocumentSnapshot): Promise<void> {
    const data = teamDoc!.data();
    if (data === null || data === undefined) {
        return;
    }
    data.objectID = 'T' + teamDoc.id;
    delete data.archived;
    delete data.admins;
    delete data.currentSeason;
    delete data.trackAttendence;
    delete data.arrivalTime;
    delete data.arriveEarly;
    data.searchRanking = 1000;
    try {
        await teamIndex.saveObjects([data]);
    } catch (e) {
        console.log('Error contacting algolia');
    }
    return;
}

export async function deleteTeam(teamId: string): Promise<void> {
    try {
        await teamIndex.deleteObjects(['T' + teamId]);
    } catch (e) {
        console.log('Error contacting algolia');
    }
    return;
}

export async function updateLeagueTeam(teamDoc: functions.firestore.DocumentSnapshot): Promise<void> {
    const data = teamDoc.data();
    data!.objectID = 't' + teamDoc.id;
    delete data!.members;
    delete data!.record;
    data!.searchRanking = 500;
    // Update the data with fun.
    const snap = await db.collection('LeagueDivison').doc(teamDoc.data()!.leagueDivisonUid).get();

    if (snap !== null && snap.exists) {
        const divisonData = snap.data();
        data!.leagueDivisonName = divisonData!.name;
        data!.leagueSeasonUid = divisonData!.seasonUid;
        const seasonSnap = await db.collection('LeagueSeason').doc(divisonData!.seasonUid).get();
        if (seasonSnap !== null && seasonSnap.exists) {
            const seasonData = seasonSnap.data();
            data!.leagueSeasonName = seasonData!.name;
            data!.leagueUid = seasonData!.leagueUid;
            const leagueSnap = await db.collection('League').doc(seasonData!.leagueUid).get();
            if (leagueSnap !== null && leagueSnap.exists) {
                const leagueData = leagueSnap.data();
                data!.leagueName = leagueData!.name;
            }
            try {
                await teamIndex.saveObjects([data!]);
            } catch (e) {
                console.log('Error contacting algolia');
            }

            return;
        }
        return;
    }
    return;
}

export async function deleteLeagueTeam(teamId: string): Promise<void> {
    try {
        await teamIndex.deleteObjects(['t' + teamId]);
    } catch (e) {
        console.log('Error contacting algolia');
    }
}

export async function updateLeague(leagueDoc: functions.firestore.DocumentSnapshot): Promise<void> {
    const data = leagueDoc.data();
    data!.objectID = 'L' + leagueDoc.id;
    delete data!.members;
    delete data!.currentSeason;
    data!.searchRanking = 900;
    let hits: ObjectWithObjectID[] = [];

    await teamIndex.browseObjects({
        query: '',
        filters: 'leagueUid="' + leagueDoc.id + '"',
        attributesToRetrieve: ['leagueDivisonName '],
        batch: (batch) => {
            hits = hits.concat(batch);
        },
    });

    // Get the records to update.
    const toUpdateRecords = new Set();
    for (const i in hits) {
        const hit = hits[i];
        toUpdateRecords.add(hit.objectID);
    }
    const records: Record<string, any>[] = [];
    toUpdateRecords.forEach((id) => {
        const pushData = { leagueDivisonName: leagueDoc!.data()!.name, objectID: id };
        records.push(pushData);
    });
    try {
        await teamIndex.partialUpdateObjects(records);
    } catch (e) {
        console.log('Error contacting algolia');
    }
}

export async function deleteLeague(teamId: string): Promise<void> {
    try {
        await teamIndex.deleteObjects(['L' + teamId]);
    } catch (e) {
        console.log('Error contacting algolia');
    }
}

export async function updateLeagueSeason(teamDoc: functions.firestore.DocumentSnapshot): Promise<void> {
    let hits: ObjectWithObjectID[] = [];

    try {
        await teamIndex.browseObjects({
            query: '',
            filters: 'leagueSeasonUid="' + teamDoc.id + '"',
            attributesToRetrieve: ['leagueSeasonName '],
            batch: (batch) => {
                hits = hits.concat(batch);
            },
        });

        // Get the records to update.
        const toUpdateRecords = new Set();
        for (const i in hits) {
            const hit = hits[i];
            toUpdateRecords.add(hit.objectID);
        }
        const records: Record<string, any>[] = [];
        toUpdateRecords.forEach((id) => {
            const data = { leagueSeasonName: teamDoc!.data()!.name, objectID: id };
            records.push(data);
        });
        await teamIndex.partialUpdateObjects(records);
    } catch (e) {
        console.log('Error contacting algolia');
    }
}

export function deleteLeagueSeason(teamId: string) {
    return;
}

export async function updateLeagueDivison(teamDoc: functions.firestore.DocumentSnapshot): Promise<void> {
    let hits: ObjectWithObjectID[] = [];

    try {
        await teamIndex.browseObjects({
            query: '',
            filters: 'leagueDivisonUid="' + teamDoc.id + '"',
            attributesToRetrieve: ['leagueDivisonName '],
            batch: (batch) => {
                hits = hits.concat(batch);
            },
        });

        // Get the records to update.
        const toUpdateRecords = new Set();
        for (const i in hits) {
            const hit = hits[i];
            toUpdateRecords.add(hit.objectID);
        }
        const records: Record<string, any>[] = [];
        toUpdateRecords.forEach((id) => {
            const data = { leagueDivisonName: teamDoc!.data()!.name, objectID: id };
            records.push(data);
        });
        await teamIndex.partialUpdateObjects(records);
    } catch (e) {
        console.log('Error contacting algolia');
    }
}

export function deleteLeagueDivison(teamId: string) {
    return;
}
