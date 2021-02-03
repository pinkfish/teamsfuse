import firebaseFunctionsTest from 'firebase-functions-test';
import * as admin from 'firebase-admin';

// Ignore the firebase app intiialize errors
admin.initializeApp();

export function firebaseTest(projectId: string) {
    return firebaseFunctionsTest({
        projectId: projectId,
    });
}
