var admin = require("firebase-admin");

var serviceAccount = require("./service-key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://teamsfuse.firebaseio.com",
});

const db = admin.firestore();

db.collection("GamesShared")
  .get()
  .then((snap) => {
    for (var index in snap.docs) {
      var myDoc = snap.docs[index];
      console.log(myDoc.data().leagueDivisionUid);
      if (
        myDoc.data().officialresult !== null &&
        myDoc.data().officialresult !== undefined
      ) {
        console.log(myDoc.id);
        db.collection("GamesShared").doc(myDoc.id).update({
          officialResult: myDoc.data().officialresult,
        });
      }
    }
  });
