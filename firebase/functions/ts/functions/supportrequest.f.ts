import * as functions from 'firebase-functions';
import { RecaptchaEnterpriseServiceClient } from '@google-cloud/recaptcha-enterprise';

const client = new RecaptchaEnterpriseServiceClient();

export const checkRecaptcha = functions.https.onRequest(async (req, res) => {
    const assessment = {
        event: {
            token: '1234',
            siteKey: '6LcKK2MaAAAAAOXAaemBVchVYv_A1FIrJAM6c50m',
        },
    };

    const projectId = 'frog';

    const formattedParent = client.projectPath(projectId!);

    const request = {
        parent: formattedParent,
        assessment: assessment,
    };

    await client.createAssessment(request);
});

export default checkRecaptcha;
