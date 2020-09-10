var admin = require('firebase-admin');

var serviceAccount = require('./service-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://teamsfuse.firebaseio.com'
});

const db = admin.firestore();

async function updateSharedGames() {
    await db.collection('GamesShared')
        .get()
        .then(snap => {
           var ret = [];
           for (var index in snap.docs) {
              ret.push((function(myDoc) {
                  var myDoc = snap.docs[index]
                  var sharedData = myDoc.data()

                  if (sharedData.officialResult != undefined) {
                      sharedData.officialResult.divisions = sharedData.officialResult.divisions.replace("GameDivisionsType.", "");
                      sharedData.officialResult.inProgress = sharedData.officialResult.divisions.replace("GameInProgress.", "");
                      sharedData.officialResult.result = sharedData.officialResult.divisions.replace("GameResult.", "");
                  }
                  sharedData.type = sharedData.type.replace("EventType.", "");
                  sharedData.uid = myDoc.id;
                  return db.collection("GamesShared").document(myDoc.id).update(sharedData);
              })(snap.docs[index]))
           }
           return Promise.all(ret);
        })
}

async function updateAllGames() {
    await db.collection("Games")
        .get()
        .then(snap => {
          var ret = []
          for (var index in snap.docs) {
            var d = snap.docs[index];
            (function(myDoc){
            var data = myDoc.data()
            if (data != null) {
                // Add in the data and update the game.
                data.result.result = data.result.result.replace("GameResult.");
                data.result.inProgress = data.result.inProgress.replace("GameInProgress.");
                data.type = data.type.replace("EventType.");
                data.uid = mydoc.id;
                ret.push( db.collection("Games").doc(myDoc.id).update(data));
            }

          })(d)
          }
        })
}

updateSharedGames()
updateAllGames()
