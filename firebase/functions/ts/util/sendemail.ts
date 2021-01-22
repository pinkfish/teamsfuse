import { AxiosInstance, AxiosResponse } from 'axios';

interface AccessTokenResponse {
    access_token: string;
}

interface SignatureResponse {
    signature: string;
}

interface IdResponse {
    id_token: string;
}

/**
 * Make request from CF to a GAE app behind IAP:
 * 1) get access token from the metadata server.
 * 2) prepare JWT and use IAM APIs projects.serviceAccounts.signBlob method to avoid bundling service account key.
 * 3) 'exchange' JWT for ID token.
 * 4) make request with ID token.
 *
 */
export async function sendEmail(from: string, to: string, subject: string, body: string, api: AxiosInstance) {
    // imports and constants
    const user_agent = 'TeamFuseWorld';
    const token_URL = 'https://www.googleapis.com/oauth2/v4/token';
    const project_id = 'teamsfuse';
    const service_account = [project_id, '@appspot.gserviceaccount.com'].join(''); // app default service account for CF project
    const target_audience = '400199897683-6ksuv7rd14c3sqvjje247njqj7ncps8c.apps.googleusercontent.com';
    const IAP_GAE_app = 'http://teamfuse.appspot.com/sendMail';

    // prepare request options and make metadata server access token request
    const url = [
        'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/',
        service_account,
        '/token',
    ].join('');
    const accessResponse = (await api({
        method: 'POST',
        url: url,
        responseType: 'json',
    })) as AxiosResponse<AccessTokenResponse>;
    if (accessResponse.status !== 200) {
        //here put what you want to do with the request
        console.log('error:', accessResponse.statusText);
        return;
    }
    // get access token from response
    const access_token = accessResponse.data.access_token;

    // prepare JWT that is {Base64url encoded header}.{Base64url encoded claim set}.{Base64url encoded signature}
    // https://developers.google.com/identity/protocols/OAuth2ServiceAccount for more info
    const JWT_header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64');
    const iat = Math.floor(new Date().getTime() / 1000);
    // prepare claims set and base64 encode it
    const claims = {
        iss: service_account,
        aud: token_URL,
        iat: iat,
        exp: iat + 60, // no need for a long lived token since it's not cached
        target_audience: target_audience,
    };
    const JWT_claimset = Buffer.from(JSON.stringify(claims)).toString('base64');

    // concatenate JWT header and claims set and get signature usign IAM APIs projects.serviceAccounts.signBlob method
    const to_sign = [JWT_header, JWT_claimset].join('.');
    // sign JWT using IAM APIs projects.serviceAccounts.signBlob method
    const signatureUrl = [
        'https://iam.googleapis.com/v1/projects/',
        project_id,
        '/serviceAccounts/',
        service_account,
        ':signBlob',
    ].join('');

    const signatureResponse = (await api({
        url: signatureUrl,
        method: 'POST',
        data: {
            bytesToSign: Buffer.from(to_sign).toString('base64'),
        },
        headers: {
            'User-Agent': user_agent,
            Authorization: ['Bearer', access_token].join(' '),
        },
    })) as AxiosResponse<SignatureResponse>;
    if (signatureResponse.status !== 200) {
        //here put what you want to do with the request
        console.log('error:', signatureResponse.statusText);
        return;
    }
    // get signature from response and form JWT
    const JWT_signature = signatureResponse.data.signature;
    const JWT = [JWT_header, JWT_claimset, JWT_signature].join('.');

    // obtain ID token
    const formResponse = (await api({
        url: token_URL,
        method: 'POST',
        data: {
            grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            assertion: JWT,
        },
    })) as AxiosResponse<IdResponse>;
    // use ID token to make a request to the IAP protected GAE app
    const ID_token = formResponse.data.id_token;
    const res = await api({
        url: IAP_GAE_app,
        headers: {
            'User-Agent': user_agent,
            Authorization: ['Bearer', ID_token].join(' '),
        },
    });
    if (res.status !== 200) {
        //here put what you want to do with the request
        console.log('error:', res.statusText);
        return;
    }

    //res.send('done');
}
