import * as admin from 'firebase-admin';
import * as _ from 'lodash';
import { updateUsers, updateAdmins } from '../../util/updateusers';
const db = admin.firestore();

export const fixUsers = function (
    id: string,
    data: Record<string, any | undefined> | undefined,
    previousData: Record<string, any | undefined> | undefined,
): Promise<any> {
    const ret: Promise<any>[] = [];

    if (data && data.user) {
        const newData = updateUsers(data.user);
        if (newData.size > 0) {
            // Do the update.
            ret.push(db.collection('Teams').doc(id).update(newData));
        }
    }
    if (data && previousData) {
        const adminSet: Set<string> = new Set(_.keys(data.admins));
        const oldAdminSet: Set<string> = new Set(_.keys(previousData.admins));
        if (!_.isEqual(adminSet, oldAdminSet)) {
            const toUpdate = updateAdmins(adminSet, oldAdminSet);
            // Go through all the seasons and update them.
            ret.push(
                db
                    .collection('Seasons')
                    .where('teamUid', '==', id)
                    .get()
                    .then((snap) => {
                        const innerRet: Promise<any>[] = [];
                        for (const docIdx in snap.docs) {
                            const doc = snap.docs[docIdx];
                            innerRet.push(db.collection('Seasons').doc(doc.id).update(toUpdate));
                        }
                        return Promise.all(innerRet);
                    }),
            );
        }
    }
    return Promise.all(ret);
};
