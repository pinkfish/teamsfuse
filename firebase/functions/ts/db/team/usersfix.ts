import * as admin from 'firebase-admin';
import * as _ from 'lodash';
import { updateUsers, updateAdmins } from '../../util/updateusers';
const db = admin.firestore();

export async function fixUsers(
    id: string,
    data: Record<string, any | undefined> | undefined,
    previousData: Record<string, any | undefined> | undefined,
): Promise<void> {
    if (data && data.user) {
        const newData = updateUsers(data.user);
        if (Object.keys(newData).length > 0) {
            // Do the update.
            await db.collection('Teams').doc(id).update({users: newData});
        }
    }
    if (data && previousData) {
        const adminSet: Set<string> = new Set(_.keys(data.admins));
        const oldAdminSet: Set<string> = new Set(_.keys(previousData.admins));
        if (!_.isEqual(adminSet, oldAdminSet)) {
            const toUpdate = updateAdmins(adminSet, oldAdminSet);
            if (Object.keys(toUpdate).length > 0) {
                // Go through all the seasons and update them.
                const snap = await db.collection('Seasons').where('teamUid', '==', id).get();
                for (const docIdx in snap.docs) {
                    const doc = snap.docs[docIdx];
                    console.log(toUpdate);
                    await db.collection('Seasons').doc(doc.id).update({users: toUpdate});
                }
            }
        }
    }
    return;
}
