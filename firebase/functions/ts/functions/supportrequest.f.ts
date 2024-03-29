import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { RecaptchaEnterpriseServiceClient } from '@google-cloud/recaptcha-enterprise';

// Client for recaptcha checks.
const client = new RecaptchaEnterpriseServiceClient();
// db to write the feedback too.
const db = admin.firestore();

// Interface to make the parsed response data less open ended.
interface ResponseData {
    name: string;
    message: string;
    email: string;
    token: string;
}

export const checkRecaptcha = functions.https.onRequest(async (req, res) => {
    if (req.method === 'POST') {
        console.log(req.body);
        // This object will accumulate all the fields, keyed by their name
        const fields: Record<string, string> = {};

        const data: ResponseData = {
            name: req.body['name'],
            message: req.body['message'],
            email: req.body['email'],
            token: req.body['token'],
        };
        const verified = await sendFeedback(data);
        if (verified) {
            res.writeHead(303, { Connection: 'close', Location: '/' });
        } else {
            res.status(405);
            res.send('<b>Unable to verify recaptcha token' + fields['token'] + '</b>');
        }
        res.end();
    } else {
        res.send('<b>Not a post message</b>');
        // Return a "method not allowed" error
        res.status(405).end();
    }
    return;
});

async function sendFeedback(data: ResponseData): Promise<boolean> {
    const projectId = 'teamsfuse';

    const formattedParent = client.projectPath(projectId!);

    const assessment = {
        event: {
            token: data.token,
            siteKey: '6LehBmUaAAAAAPYH2v-BdZrlmg50VZER8mmsCMTq',
        },
    };
    const request = {
        parent: formattedParent,
        assessment: assessment,
    };

    const [result] = await client.createAssessment(request);
    if (result && result.riskAnalysis && result.riskAnalysis.score! > 0.5) {
        await db.collection('Feedback').add({
            name: data.name,
            message: data.message,
            email: data.email,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return true;
    } else {
        return false;
    }
}

export default checkRecaptcha;
