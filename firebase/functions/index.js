const functions = require('firebase-functions');
const path = require('path');
const glob = require('glob');
const admin = require('firebase-admin');
const settings = { timestampsInSnapshots: true };
const detectMocha = require('detect-mocha');

const ENDPOINT_FOLDER = '.';
const DO_NOT_DEPLOY = /^(admin|a|debug|d)$/;
const IGNORE = /^(ignore|i)$/;
const BREAK_ON_ERROR = true;

admin.initializeApp();
admin.firestore().settings(settings);

const is = {
    emulating: process.env.hasOwnProperty('FIREBASE_PROJECT'),
    deploying: !process.env.hasOwnProperty('FUNCTION_NAME'),
};

let skipped = [];
glob.sync(`./**/*.f.js`, {
    cwd: path.resolve(__dirname, ENDPOINT_FOLDER),
})
    .map(file => ({
        path: file.slice(2),
        components: file.slice(2, -5).split(/[\/.]/g),
    }))
    .sort((a, b) => b.components.length - a.components.length)
    .forEach(file => {
        // ignore by name
        if (file.components.find(c => IGNORE.test(c))) return;

        // firebase naming standard
        const FB_NAME = file.components.join('-');

        // function is currently being triggered
        is.triggered = process.env.FUNCTION_NAME === FB_NAME;

        // only deploy files locally or if allowed to deploy
        is.deployable = is.emulating || !file.components.find(c => DO_NOT_DEPLOY.test(c));

        // export module if triggered or deploying
        if (is.triggered || (is.deploying && is.deployable)) {
            // map the module to a deep path: { [component]: { [component]: module } }
            file.components.reduce((_, c, i, list) => {
                // get the map for each path component
                if (i < list.length - 1) {
                    if (!_[c]) _[c] = {};
                    return _[c];
                }

                // skip files where a naming conflict exists with a directory
                if (_[c]) return skipped.push(`./${file.path.slice(0, -3)}`);

                // export the module
                _[c] = require(`./${ENDPOINT_FOLDER}/${file.path}`);
                _[c] = _[c].default || _[c];
            }, exports);
        }
    });

// don't allow conflicts to deploy
if (BREAK_ON_ERROR && skipped.length) {
    throw new Error(`naming conflict: "${skipped.join('", "')}"`);
}
