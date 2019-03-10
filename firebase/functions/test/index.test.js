const firebase = require("@firebase/testing");
const fs = require("fs");

/*
 * ============
 *    Setup
 * ============
 */
const projectName = "test-teamsfuse";
const coverageUrl = `http://localhost:8080/emulator/v1/projects/${projectName}:ruleCoverage.html`;

const rules = fs.readFileSync("../firestore.rules", "utf8");

/**
 * Creates a new app with authentication data matching the input.
 *
 * @param {object} auth the object to use for authentication (typically {uid: some-uid})
 * @return {object} the app.
 */
function authedApp(auth) {
  return firebase
    .initializeTestApp({ projectId: projectName, auth })
    .firestore();
}

/*
 * ============
 *  Test Cases
 * ============
 */
beforeEach(async () => {
  // Clear the database between tests
  await firebase.clearFirestoreData({
    projectId: projectName
  });
  console.log("end beforeEach");
});

before(async () => {
  await firebase.loadFirestoreRules({
    projectId: projectName,
    rules: rules
  });
  console.log("end before");
});

after(async () => {
  await Promise.all(firebase.apps().map(app => app.delete()));
  console.log(`View rule coverage information at ${coverageUrl}\n`);
});

describe("My app", () => {
  it("require users to log in before listing teams", async () => {
    const db = authedApp(null);
    const doc = db.collection("Teams").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing clubs", async () => {
    const db = authedApp(null);
    const doc = db.collection("Clubs").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing games", async () => {
    const db = authedApp(null);
    const doc = db.collection("Games").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing games shared", async () => {
    const db = authedApp(null);
    const doc = db.collection("GamesShared").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing invites", async () => {
    const db = authedApp(null);
    const doc = db.collection("Invites").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("everyone can list league", async () => {
    const db = authedApp(null);
    const doc = db.collection("League").doc("frog");
    await firebase.assertSucceeds(doc.get());
  });
  it("everyone can list league divison", async () => {
    const db = authedApp(null);
    const doc = db.collection("LeagueDivision").doc("frog");
    await firebase.assertSucceeds(doc.get());
  });
  it("everyone can list league season", async () => {
    const db = authedApp(null);
    const doc = db.collection("LeagueSeason").doc("frog");
    await firebase.assertSucceeds(doc.get());
  });
  it("everyone can list league team", async () => {
    const db = authedApp(null);
    const doc = db.collection("LeagueTeam").doc("frog");
    await firebase.assertSucceeds(doc.get());
  });
  it("require users to log in before listing message recipients", async () => {
    const db = authedApp(null);
    const doc = db.collection("MessageRecipients").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing messages", async () => {
    const db = authedApp(null);
    const doc = db.collection("Messages").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing players", async () => {
    const db = authedApp(null);
    const doc = db.collection("Players").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before listing seasons", async () => {
    const db = authedApp(null);
    const doc = db.collection("Seasons").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("require users to log in before teams", async () => {
    const db = authedApp(null);
    const doc = db.collection("Teams").doc("frog");
    await firebase.assertFails(doc.get());
  });
  it("should enforce the createdAt date in user profiles", async () => {
    const db = authedApp({ uid: "alice" });
    const profile = db.collection("UserData").doc("alice");
    await firebase.assertFails(profile.set({ birthday: "January 1" }));
    await firebase.assertSucceeds(
      profile.set({
        birthday: "January 1",
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
      })
    );
  });
});

/*
// Chai is a commonly used library for creating unit test suites. It is easily extended with plugins.
const chai = require('chai');
const assert = chai.assert;

// Sinon is a library used for mocking or verifying function calls in JavaScript.
const sinon = require('sinon');


// Require firebase-admin so we can stub out some of its methods.
const admin = require('firebase-admin');
const firestore = require('@google-cloud/firestore');
const convert = require('./convert.js');

   const test = require('firebase-functions-test')();

   const is = require("is");
           const fs = admin.firestore;


class DocumentSnapshotBuilder {
    build() {
        assert((this.fieldsProto !== undefined) === (this.createTime !== undefined), 'Create time should be set iff document exists.');
        assert((this.fieldsProto !== undefined) === (this.updateTime !== undefined), 'Update time should be set iff document exists.');
        console.log(this.fieldsProto);
        return this.fieldsProto ?
            new firestore.QueryDocumentSnapshot(this.ref, this.fieldsProto, this.readTime, this.createTime, this.updateTime) :
            new firestore.DocumentSnapshot(this.ref, undefined, this.readTime);
    }
}

   class Froggy {
     constructor() {
        this._serializer = {
                           encodeFields : function(data) { return data; },
                           decodeValue : function(data) {

                           return data.mapValue.fields;
                           }
                         }
     ;


     }

  settings() {
  }


  snapshot_(documentOrName, readTime, encoding) {
                                                      // TODO: Assert that Firestore Project ID is valid.
                                                      let convertTimestamp;
                                                      let convertDocument;
                                                      if (!is.defined(encoding) || encoding === 'protobufJS') {
                                                          convertTimestamp = data => data;
                                                          convertDocument = data => data;
                                                      }
                                                      else if (encoding === 'json') {
                                                          // Google Cloud Functions calls us with Proto3 JSON format data, which we
                                                          // must convert to Protobuf JS.
                                                          convertTimestamp = convert.timestampFromJson;
                                                          convertDocument = convert.documentFromJson;
                                                      }
                                                      else {
                                                          throw new Error(`Unsupported encoding format. Expected "json" or "protobufJS", ` +
                                                              `but was "${encoding}".`);
                                                      }
                                                     const document = new DocumentSnapshotBuilder();
                                                      if (typeof documentOrName === 'string') {
                                                          document.ref = new firestore.DocumentReference(this, documentOrName);
                                                      }
                                                      else {
                                                          document.ref = new firestore.DocumentReference(this, documentOrName.name);
                                                          document.fieldsProto =
                                                              documentOrName.fields ? convertDocument(documentOrName.fields) : {};
                                                          document.createTime = firestore.Timestamp.fromProto(convertTimestamp(documentOrName.createTime, 'documentOrName.createTime'));
                                                          document.updateTime = firestore.Timestamp.fromProto(convertTimestamp(documentOrName.updateTime, 'documentOrName.updateTime'));
                                                      }
                                                      if (readTime) {
                                                          document.readTime =
                                                              firestore.Timestamp.fromProto(convertTimestamp(readTime, 'readTime'));
                                                      }
                                                      return document.build();
                                                  };


}

describe('Cloud Functions', () => {
    let myFunctions, adminInitStub, myDb, firestoreInitStub;

    before(() => {
        // If index.js calls admin.initializeApp at the top of the file,
        // we need to stub it out before requiring index.js. This is because the
        // functions will be executed as a part of the require process.
        // Here we stub admin.initializeApp to be a dummy function that doesn't do anything.

        Object.defineProperty(admin, "firestore", {
                  get: function () {
                  stuff = function() { return new Froggy(); }
                  stuff.Timestamp = fs.Timestamp;
                  stuff.DocumentReference = fs.DocumentReference;
                  stuff.snapshot_ = function(documentOrName, readTime, encoding) {
                                                   // TODO: Assert that Firestore Project ID is valid.
                                                    let convertTimestamp;
                                                    let convertDocument;
                                                    if (!is.defined(encoding) || encoding === 'protobufJS') {
                                                        convertTimestamp = data => data;
                                                        convertDocument = data => data;
                                                    }
                                                    else if (encoding === 'json') {
                                                        // Google Cloud Functions calls us with Proto3 JSON format data, which we
                                                        // must convert to Protobuf JS.
                                                        convertTimestamp = convert.timestampFromJson;
                                                        convertDocument = convert.documentFromJson;
                                                    }
                                                    else {
                                                        throw new Error(`Unsupported encoding format. Expected "json" or "protobufJS", ` +
                                                            `but was "${encoding}".`);
                                                    }
                                                    const document = new document_1.DocumentSnapshotBuilder();
                                                    if (typeof documentOrName === 'string') {
                                                        document.ref = new reference_2.DocumentReference(this, path_2.ResourcePath.fromSlashSeparatedString(documentOrName));
                                                    }
                                                    else {
                                                        document.ref = new reference_2.DocumentReference(this, path_2.ResourcePath.fromSlashSeparatedString(documentOrName.name));
                                                        document.fieldsProto =
                                                            documentOrName.fields ? convertDocument(documentOrName.fields) : {};
                                                        document.createTime = timestamp_1.Timestamp.fromProto(convertTimestamp(documentOrName.createTime, 'documentOrName.createTime'));
                                                        document.updateTime = timestamp_1.Timestamp.fromProto(convertTimestamp(documentOrName.updateTime, 'documentOrName.updateTime'));
                                                    }
                                                    if (readTime) {
                                                        document.readTime =
                                                            timestamp_1.Timestamp.fromProto(convertTimestamp(readTime, 'readTime'));
                                                    }
                                                    return document.build();
                                                };

                  return stuff;
             },
             enumerable: true,
             configurable: true
         });

        adminInitStub = sinon.stub(admin, 'initializeApp');
        test.mockConfig({
            mailgun: { apikey: '23wr42ewr34', domain: 'frog.com' },
            algolia: { appid: 'rabbit', key: 'crystal'}
            });
        console.log('rabbit');
        // Now we can require index.js and save the exports inside a namespace called myFunctions.
        myFunctions = require('../index.js');
        console.log('fluff');
    });

    after(() => {
        // Restore the method and cleanup.
        adminInitStub.restore();
        //firestoreInitStub.restore();
       test.cleanup();
    });

    describe('ongameupdate', () => {
        it('Nothing to update', () => {
            const afterData =
                {
                    result: {
                        inProgress: "GameInProgress.NotStarted",
                        result: "GameResult.Unknown",
                        period: 'Regulation',
                        scores: {
                            Regulation: {
                                ptsAgainst: 10,
                                ptsFor: 10
                            }
                        },
                    }
                }
            const beforeData =
                      {
                          result: {
                              inProgress: "GameInProgress.NotStarted",
                              result: "GameResult.Unknown",
                              period: 'Regulation',
                              scores: {
                                  Regulation: {
                                      ptsAgainst: 10,
                                      ptsFor: 10
                                  }
                              },
                          }
                      }
            const beforeSnap = test.firestore.makeDocumentSnapshot(beforeData, 'Games/1234');
            const afterSnap = test.firestore.makeDocumentSnapshot(afterData, 'Games/1234');
            console.log('data');
            const change = test.makeChange(beforeSnap, afterSnap);
            console.log(beforeSnap.data().result.stringValue);

            const wrapped = test.wrap(myFunctions.dbGameresultnotify);
            wrapped(change);
            return true;
        });
    });
});


*/
