import * as admin from 'firebase-admin';
import * as _ from 'lodash';
import { updateAdmins } from '../../util/updateusers';
const db = admin.firestore();

export async function fixUsers(
    id: string,
    data: Record<string, any | undefined>,
    previousData: Record<string, any | undefined>,
): Promise<void> {
    // If a club is added, then we update the admin set.
    if (data.clubUid !== null && data.clubUid !== undefined) {
        if (data.clubUid !== previousData.clubUid) {
            const clubRef = await db.collection('Clubs').doc(data.clubUid).get();
            // Add the admins to the team and seasons.
            const clubData = clubRef.data();
            if (clubData !== null && clubData !== undefined) {
                const members = clubData.members;
                // The set to update for the team
                const teamUpdate: Record<string, any> = {};
                const seasonUpdate: Record<string, any> = {};
                for (const memIdx in members) {
                    const memberData = members[memIdx];
                    if (memberData.admin) {
                        teamUpdate['admins.' + memIdx] = true;
                        seasonUpdate['admins.' + memIdx] = true;
                    }
                    teamUpdate['users.' + memIdx + '.club'] = true;
                    teamUpdate['users.' + memIdx + '.added'] = true;
                    seasonUpdate['users.' + memIdx + '.club'] = true;
                    seasonUpdate['users.' + memIdx + '.added'] = true;
                }
                if (Object.keys(teamUpdate).length > 0) {
                    await db.collection('Teams').doc(id).update(teamUpdate);
                    if (Object.keys(seasonUpdate).length > 0) {
                        const snap = await db.collection('Seasons').where('teamUid', '==', id).get();
                        for (const docIdx in snap.docs) {
                            const doc = snap.docs[docIdx];
                            await db.collection('Seasons').doc(doc.id).update(seasonUpdate);
                        }
                    }
                }
            }
        }
    }

    const adminSet: Set<string> = new Set(_.keys(data.admins));
    const oldAdminSet: Set<string> = new Set(_.keys(previousData.admins));
    if (!_.isEqual(adminSet, oldAdminSet)) {
        const toUpdate = updateAdmins(adminSet, oldAdminSet);
        if (Object.keys(toUpdate).length > 0) {
            // Go through all the seasons and update them.
            const snap = await db.collection('Seasons').where('teamUid', '==', id).get();
            for (const docIdx in snap.docs) {
                const doc = snap.docs[docIdx];
                await db.collection('Seasons').doc(doc.id).update({ users: toUpdate });
            }
        }
    }

    return;
}
