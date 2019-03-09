// Chai is a commonly used library for creating unit test suites. It is easily extended with plugins.
const chai = require('chai');
const assert = chai.assert;

// Sinon is a library used for mocking or verifying function calls in JavaScript.
const sinon = require('sinon');

// Require firebase-admin so we can stub out some of its methods.
const admin = require('firebase-admin');
// Require and initialize firebase-functions-test. Since we are not passing in any parameters, it will
// be initialized in an "offline mode", which means we have to stub out all the methods that interact
// with Firebase services.
const test = require('firebase-functions-test')();

describe('Cloud Functions', () => {
    let myFunctions, adminInitStub, myDb;

    before(() => {
        console.log('before');
        // If index.js calls admin.initializeApp at the top of the file,
        // we need to stub it out before requiring index.js. This is because the
        // functions will be executed as a part of the require process.
        // Here we stub admin.initializeApp to be a dummy function that doesn't do anything.
        adminInitStub = sinon.stub(admin, 'initializeApp');
        // Now we can require index.js and save the exports inside a namespace called myFunctions.
        myFunctions = require('../db/gameresultnotify.f.js');
    });

    after(() => {
        // Restore the method and cleanup.
        adminInitStub.restore();
        test.cleanup();
    });

    describe('ongameupdate', () => {
        it('Nothing to update', () => {
            const afterData =
                {
                    result: {
                        inProgress: "GameInProgress.NotStarted",
                        result: "GameResult.Unknown",
                        scores: {
                            Final: {
                                ptsAgainst: 10,
                                ptsFor: 10
                            }
                        }
                    }
                }
            const beforeData =
                      {
                          result: {
                              inProgress: "GameInProgress.NotStarted",
                              result: "GameResult.Unknown",
                              scores: {
                                  Final: {
                                      ptsAgainst: 10,
                                      ptsFor: 10
                                  }
                              }
                          }
                      }
            const beforeSnap = test.firestore.makeDocumentSnapshot(beforeData, 'Games/1234');
            const afterSnap = test.firestore.makeDocumentSnapshot(afterData, 'Games/1234');
            const change = test.makeChange(beforeSnap, afterSnap);

            const wrapped = test.wrap(myFunctions.dbGameresultnotify);
            wrapped(change);
            return true;
        });
    });
});


