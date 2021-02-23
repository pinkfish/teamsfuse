import * as functions from 'firebase-functions';
import Busboy = require('busboy');
import * as admin from 'firebase-admin';
import { RecaptchaEnterpriseServiceClient } from '@google-cloud/recaptcha-enterprise';

// Client for recaptcha checks.
const client = new RecaptchaEnterpriseServiceClient();
// db to write the feedback too.
const db = admin.firestore();

export const checkRecaptcha = functions.https.onRequest(async (req, res) => {
    if (req.method === 'POST') {
        const myBusboy = new Busboy({ headers: req.headers });

        // This object will accumulate all the fields, keyed by their name
        const fields: Record<string, string> = {};

        // This code will process each non-file field in the form.
        myBusboy.on('field', (fieldname, val) => {
            console.log(`Processed field ${fieldname}: ${val}.`);
            fields[fieldname] = val;
        });

        myBusboy.on('finish', async function () {
            const verified = await sendFeedback(
                fields['name'],
                fields['message'],
                fields['email'],
                fields['g-recaptcha-response'],
            );
            if (verified) {
                res.writeHead(303, { Connection: 'close', Location: '/' });
            } else {
                res.status(405);
            }
            res.end();
        });
        req.pipe(myBusboy);
    } else {
        // Return a "method not allowed" error
        res.status(405).end();
    }
    return;
});

async function sendFeedback(name: string, message: string, email: string, token: string): Promise<boolean> {
    const projectId = 'teamsfuse';

    const formattedParent = client.projectPath(projectId!);

    const assessment = {
        event: {
            token: token,
            siteKey: "6LehBmUaAAAAAPYH2v-BdZrlmg50VZER8mmsCMTq",
        },
    };
    const request = {
        parent: formattedParent,
        assessment: assessment,
    };

    const [result] = await client.createAssessment(request);
    if (result && result.riskAnalysis && result.riskAnalysis.score! > 0.5) {
        await db.collection('Feedback').add({
            name: name,
            message: message,
            email: email,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return true;
    } else {
        return false;
    }
}

export default checkRecaptcha;
