/**
 * Make request from CF to a GAE app behind IAP:
 * 1) get access token from the metadata server.
 * 2) prepare JWT and use IAM APIs projects.serviceAccounts.signBlob method to avoid bundling service account key.
 * 3) 'exchange' JWT for ID token.
 * 4) make request with ID token.
 *
 */
exports.sendEmail = (from, to, subject, body) => {
  // imports and constants
  const request = require('request');
  const user_agent = 'TeamFuseWorld';
  const token_URL = "https://www.googleapis.com/oauth2/v4/token";
  const project_id = 'teamsfuse';
  const service_account = [project_id,
                           '@appspot.gserviceaccount.com'].join(''); // app default service account for CF project
  const target_audience = '400199897683-6ksuv7rd14c3sqvjje247njqj7ncps8c.apps.googleusercontent.com';
  const IAP_GAE_app = 'http://teamfuse.appspot.com/sendMail';

  // prepare request options and make metadata server access token request
  var meta_req_opts = {
    url: ['http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/',
          service_account,
          '/token'].join(''),
    headers: {
      'User-Agent': user_agent,
      'Metadata-Flavor': 'Google'
    }
  };
  request(meta_req_opts, (err, res, body) => {
    if (err || res.statusCode === 200) {
      //here put what you want to do with the request
      console.log('error:', err);
      return;
    }
    // get access token from response
    var meta_resp_data = JSON.parse(body);
    var access_token = meta_resp_data.access_token;

    // prepare JWT that is {Base64url encoded header}.{Base64url encoded claim set}.{Base64url encoded signature}
    // https://developers.google.com/identity/protocols/OAuth2ServiceAccount for more info
    var JWT_header = new Buffer(JSON.stringify({ alg: "RS256", typ: "JWT" })).toString('base64');
    var iat = Math.floor(new Date().getTime() / 1000);
    // prepare claims set and base64 encode it
    var claims = {
      iss: service_account,
      aud: token_URL,
      iat: iat,
      exp: iat + 60, // no need for a long lived token since it's not cached
      target_audience: target_audience
    };
    var JWT_claimset = new Buffer(JSON.stringify(claims)).toString('base64');

    // concatenate JWT header and claims set and get signature usign IAM APIs projects.serviceAccounts.signBlob method
    var to_sign = [JWT_header, JWT_claimset].join('.');
    // sign JWT using IAM APIs projects.serviceAccounts.signBlob method
    var signature_req_opts = {
      url: ['https://iam.googleapis.com/v1/projects/',
            project_id,
            '/serviceAccounts/',
            service_account,
            ':signBlob'].join(''),
      method: "POST",
      json: {
        "bytesToSign": new Buffer(to_sign).toString('base64')
      },
      headers: {
        'User-Agent': user_agent,
        'Authorization': ['Bearer', access_token].join(' ')
      }
    };
    request(signature_req_opts, (err, res, body) => {
      if (err || res.statusCode === 200) {
        //here put what you want to do with the request
        console.log('error:', err);
        return;
      }

      // get signature from response and form JWT
      var JWT_signature = body.signature;
      var JWT = [JWT_header, JWT_claimset, JWT_signature].join('.');

      // obtain ID token
      request.post({url:token_URL, form: {grant_type:'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion:JWT}}, (err, res, body) => {
        if (err || res.statusCode === 200) {
            //here put what you want to do with the request
            console.log('error:', err);
            return;
        }
        // use ID token to make a request to the IAP protected GAE app
        var ID_token_resp_data = JSON.parse(body);
        var ID_token = ID_token_resp_data.id_token;
        var IAP_req_opts = {
          url: IAP_GAE_app,
          headers: {
            'User-Agent': user_agent,
            'Authorization': ['Bearer', ID_token].join(' ')
          }
        };
        request(IAP_req_opts, (err, res, body) => {
          if (err || res.statusCode === 200) {
            //here put what you want to do with the request
            console.log('error:', err);
            return;
          }
          console.log('error:', err);
        });
      });
    });
  });
  res.send('done');
};