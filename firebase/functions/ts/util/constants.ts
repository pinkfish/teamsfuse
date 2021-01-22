import * as admin from 'firebase-admin';

export const BUCKET_NAME = 'teamsfuse.appspot.com';

export const FIREBASE_APP_OPTIONS: admin.AppOptions = {
    storageBucket: BUCKET_NAME,
};
