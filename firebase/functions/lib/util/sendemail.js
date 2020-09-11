"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendEmail = void 0;
const request = require("request");
/**
 * Make request from CF to a GAE app behind IAP:
 * 1) get access token from the metadata server.
 * 2) prepare JWT and use IAM APIs projects.serviceAccounts.signBlob method to avoid bundling service account key.
 * 3) 'exchange' JWT for ID token.
 * 4) make request with ID token.
 *
 */
async function sendEmail(from, to, subject, body) {
    // imports and constants
    const user_agent = 'TeamFuseWorld';
    const token_URL = 'https://www.googleapis.com/oauth2/v4/token';
    const project_id = 'teamsfuse';
    const service_account = [project_id, '@appspot.gserviceaccount.com'].join(''); // app default service account for CF project
    const target_audience = '400199897683-6ksuv7rd14c3sqvjje247njqj7ncps8c.apps.googleusercontent.com';
    const IAP_GAE_app = 'http://teamfuse.appspot.com/sendMail';
    // prepare request options and make metadata server access token request
    const meta_req_opts = {
        url: [
            'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/',
            service_account,
            '/token',
        ].join(''),
        headers: {
            'User-Agent': user_agent,
            'Metadata-Flavor': 'Google',
        },
    };
    await request(meta_req_opts, (err, res, requestBody) => {
        if (err || res.statusCode === 200) {
            //here put what you want to do with the request
            console.log('error:', err);
            return;
        }
        // get access token from response
        const meta_resp_data = JSON.parse(requestBody);
        const access_token = meta_resp_data.access_token;
        // prepare JWT that is {Base64url encoded header}.{Base64url encoded claim set}.{Base64url encoded signature}
        // https://developers.google.com/identity/protocols/OAuth2ServiceAccount for more info
        const JWT_header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64');
        const iat = Math.floor(new Date().getTime() / 1000);
        // prepare claims set and base64 encode it
        const claims = {
            iss: service_account,
            aud: token_URL,
            iat: iat,
            exp: iat + 60,
            target_audience: target_audience,
        };
        const JWT_claimset = Buffer.from(JSON.stringify(claims)).toString('base64');
        // concatenate JWT header and claims set and get signature usign IAM APIs projects.serviceAccounts.signBlob method
        const to_sign = [JWT_header, JWT_claimset].join('.');
        // sign JWT using IAM APIs projects.serviceAccounts.signBlob method
        const signature_req_opts = {
            url: [
                'https://iam.googleapis.com/v1/projects/',
                project_id,
                '/serviceAccounts/',
                service_account,
                ':signBlob',
            ].join(''),
            method: 'POST',
            json: {
                bytesToSign: Buffer.from(to_sign).toString('base64'),
            },
            headers: {
                'User-Agent': user_agent,
                Authorization: ['Bearer', access_token].join(' '),
            },
        };
        request(signature_req_opts, (signatureErr, signatureRes, innerRequest) => {
            if (signatureErr || signatureRes.statusCode === 200) {
                //here put what you want to do with the request
                console.log('error:', signatureErr);
                return;
            }
            // get signature from response and form JWT
            const JWT_signature = innerRequest.signature;
            const JWT = [JWT_header, JWT_claimset, JWT_signature].join('.');
            // obtain ID token
            request.post({
                url: token_URL,
                form: {
                    grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                    assertion: JWT,
                },
            }, (tokenErr, tokenRes, idRequest) => {
                if (tokenErr || tokenRes.statusCode === 200) {
                    //here put what you want to do with the request
                    console.log('error:', tokenErr);
                    return;
                }
                // use ID token to make a request to the IAP protected GAE app
                const ID_token_resp_data = JSON.parse(idRequest);
                const ID_token = ID_token_resp_data.id_token;
                const IAP_req_opts = {
                    url: IAP_GAE_app,
                    headers: {
                        'User-Agent': user_agent,
                        Authorization: ['Bearer', ID_token].join(' '),
                    },
                };
                request(IAP_req_opts, (iapErr, iapRes, iapRequest) => {
                    if (iapErr || iapRes.statusCode === 200) {
                        //here put what you want to do with the request
                        console.log('error:', iapErr);
                        return;
                    }
                    console.log('error:', iapErr);
                });
            });
        });
    });
    //res.send('done');
}
exports.sendEmail = sendEmail;
//# sourceMappingURL=sendemail.js.map