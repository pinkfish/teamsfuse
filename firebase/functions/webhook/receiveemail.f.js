const functions = require('firebase-functions');
// CORS Express middleware to enable CORS Requests.
const cors = require('cors')({
  origin: true,
});

exports = module.exports = functions.https.onRequest((req, res) => {
    if (req.method !== 'POST') {
        return res.status(403).send('Forbidden!');
    }

    return cors(req, res, () => {
        // Reading date format from URL query parameter.
        let subject = req.query.subject;
        let text = req.query['body-html'];
        let html = req.query['body-plain'];

        console.log(req.query);

        res.status(200).send('Stuff ' + text);
    });
});
