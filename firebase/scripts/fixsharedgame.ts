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
                  return db.collection("Games")
                      .where("sharedDataUid", "==", myDoc.id)
                      .get()
                      .then(snapshot => {
                          var inner = [];
    
                          if (snapshot.docs.length == 0) {
                             console.log('Docs for ' + myDoc.id);
                          }
                          for (var index in snapshot.docs) {
                            inner.push((function(gameDoc) {
                                return db.collection("Games").doc(gameDoc.id).update({
                                   'sharedData': sharedData
                                })
                                console.log('Updated ' + gameDoc.id)
                            })(snapshot.docs[index]))
                          }
                          if (snapshot.docs.length == 0) {
                             console.log('Fo0und no docs for ' + myDoc.id);
                          }
                          return Promise.all(inner);
                      });
                  
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
            if (data != null && data.sharedDataUid == null) {
                var sharedData = {
                  endTime: data.endTime,
                  name: data.name,
                  place: data.place,
                  time: data.time,
                  timezone: data.timezone,
                  type: data.type,
                  leagueDivisonUid: null,
                  leagueUid: null,
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
//updateAllGames()
