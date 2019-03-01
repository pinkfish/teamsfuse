'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');

var db = admin.firestore();


exports = module.exports = functions.firestore.document("/Players/{playerid}")
    .onWrite((inputData, context) => {
    /* No longer need to do this.
  const data = inputData.after.data();
  const previousData = inputData.before.data();

  // See if the name is different.
  if ((data.name !== null && data.name !== previousData.name) ||
      (data.photourl !== null && data.photourl !== previousData.photourl)) {
    console.log('update!', inputData.after.id);
    // Update everywhere.
    return db.collection("Seasons")
       .where("players." + inputData.after.id + ".added", "==", true).get()
       .then(snapshot => {
         var docsStuff = []
         snapshot.docs.forEach(doc => {
           var snap = {}
           snap['players.' + inputData.after.id + '.name'] = data.name
	       if (data.photourl !== undefined) {
             snap['players.' + inputData.after.id + '.photourl'] = data.photourl
           }
           docsStuff.push(doc.ref.update(snap));
         });
         return Promise.all(docsStuff);
       });
  }
  */

  return inputData.after.data();
});
