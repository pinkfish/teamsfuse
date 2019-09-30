var admin = require('firebase-admin');

var serviceAccount = require('./service-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://teamsfuse.firebaseio.com"
});

const db = admin.firestore();

async function updateSeasons(playerId, user) {
    await db.collection('Seasons')
        .where("players." + playerId + ".added", "==", true)
        .get()
        .then(snap => {
           var ret = [];
           for (var index in snap.docs) {
              var myDoc = snap.docs[index]
              var updateData = {

              }
              updateData["users." + user + ".added"] = true;
              updateData["users." + user + "." + playerId] = true;
              console.log('Updating season ' + myDoc.id + ' player ' + playerId + ' user ' + user);
              ret.push(db.collection("Seasons")
                  .doc(myDoc.id)
                  .update(updateData));

              console.log('Updating team ' + myDoc.data().teamUid  + ' player ' + playerId + ' user ' + user);
              ret.push(db.collection("Teams")
                  .doc(myDoc.data().teamUid)
                  .update(updateData));

           }
           return Promise.all(ret);
        })
}

async function updateAllSeasons() {
    await db.collection("Players")
        .get()
        .then(snap => {
          var ret = []
          for (var index in snap.docs) {
            var d = snap.docs[index];
            console.log('Checking player ' + d.id);
            (function(myPlayer){
            var data = myPlayer.data()
console.log(myPlayer.data().user);
            if (data != null && data.sharedDataUid == null) {
               // Updatew all the users for this player.
               for (var idx in myPlayer.data().user) {
                    updateSeasons(myPlayer.id, idx);
               }
            }
          })(d)
          }
        })
}

updateAllSeasons()
