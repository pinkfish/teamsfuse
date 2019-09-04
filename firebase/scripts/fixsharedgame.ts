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
              var myDoc = snap.docs[index]
              ret.push(db.collection("Games")
                  .where("sharedDataUid", "==", myDoc.id)
                  .get()
                  .then(snapshot => {
                      var inner = [];

                      for (var index in snapshot.docs) {
                        var gameDoc = snapshot.docs[index]

                        inner.push( db.collection("Games").doc(gameDoc.id).update({
                           sharedData: myDoc.data(),
                        }))
                        console.log('Updated ' + gameDoc.id)
                      }
                      return Promise.all(inner);
                  })
              )
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
            if (data != null && data.sharedDataUid == null) {
                sharedData = {
                  endTime: data.endTime,
                  name: data.name,
                  place: data.place,
                  time: data.time,
                  timezone: data.timezone,
                  type: data.type
                }
                if (data.leagueDivisonUid) {
                  sharedData.leagueDivisonUid = data.leagueDivisonUid
                  sharedData.leagueUid = data.leagueUid
                }
                // Add in the data and update the game.
                ret.push(db.collection("GamesShared").add(sharedData).then(ref => {
                   console.log("Updated " + myDoc.id + " with " + ref.id);
                   return db.collection("Games").doc(myDoc.id).update({sharedDataUid: ref.id})
                }))
            }

          })(d)
          }
        })
}

updateSharedGames()
updateAllGames()