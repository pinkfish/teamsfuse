var admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");
const dotenv = require("dotenv");

var serviceAccount = require("./service-key.json");

dotenv.load();

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://teamsfuse.firebaseio.com",
});

const db = admin.firestore();

// configure algolia
const algolia = algoliasearch(
  process.env.ALGOLIA_APP_ID,
  process.env.ALGOLIA_API_KEY
);
const searchIndex = algolia.initIndex(process.env.ALGOLIA_INDEX_NAME);
const teamIndex = algolia.initIndex("teams");

db.collection("League")
  .get()
  .then((snap) => {
    const records = [];
    for (var index in snap.docs) {
      var myDoc = snap.docs[index];
      var data = myDoc.data();
      data.objectID = "L" + myDoc.id;
      delete data.members;
      delete data.currentSeason;
      data.searchRanking = 900;
      records.push(data);
    }
    teamIndex
      .saveObjects(records)
      .then(() => {
        console.log("League imported to algolia");
      })
      .catch((error) => {
        console.log("Error importing league to algolia", error);
      });
  });

db.collection("LeagueTeam")
  .get()
  .then((snap) => {
    const records = [];
    const divisonToLookup = new Set();
    for (var index in snap.docs) {
      var myDoc = snap.docs[index];
      var data = myDoc.data();
      data.objectID = "t" + myDoc.id;
      delete data.members;
      delete data.record;
      divisonToLookup.add(data.leagueDivisonUid);
      data.searchRanking = 500;
      records.push(data);
    }
    // Lookup all the divisons.
    const details = [];
    console.log(divisonToLookup);
    divisonToLookup.forEach((div) => {
      console.log(div);
      details.push(db.collection("LeagueDivision").doc(div).get());
    });
    Promise.all([records, Promise.all(details)])
      .then((data) => {
        const records = data[0];
        const divisons = data[1];
        const seasonToLookup = new Set();
        const divLookup = {};

        for (var i in divisons) {
          var div = divisons[i];
          console.log(div.data());
          seasonToLookup.add(div.data().seasonUid);
          divLookup[div.id] = div.data();
        }
        for (var index in records) {
          var divison = divLookup[records[index].leagueDivisonUid];
          records[index].leagueDivisonName = divison.name;
          records[index].leagueSeasonUid = divison.seasonUid;
        }
        const details = [];
        seasonToLookup.forEach((season) => {
          console.log(season);
          details.push(db.collection("LeagueSeason").doc(season).get());
        });
        return Promise.all([records, Promise.all(details)]);
      })
      .then((data) => {
        const record = data[0];
        const seasons = data[1];
        const leagueToLookup = new Set();
        const divLookup = {};

        for (var i in seasons) {
          var season = seasons[i];
          console.log(season.data());
          leagueToLookup.add(season.data().leagueUid);
          divLookup[season.id] = season.data();
        }
        for (var index in records) {
          var divison = divLookup[records[index].leagueSeasonUid];
          records[index].leagueSeasonName = divison.name;
          records[index].leagueUid = divison.leagueUid;
        }
        const details = [];
        leagueToLookup.forEach((l) => {
          console.log(l);
          details.push(db.collection("League").doc(l).get());
        });
        return Promise.all([records, Promise.all(details)]);
      })
      .then((data) => {
        const record = data[0];
        const leagues = data[1];
        const divLookup = {};

        for (var i in leagues) {
          var l = leagues[i];
          divLookup[l.id] = l.data();
        }
        for (var index in records) {
          var divison = divLookup[records[index].leagueUid];
          records[index].leagueName = divison.name;
        }
        teamIndex
          .saveObjects(records)
          .then(() => {
            console.log("League imported to algolia");
          })
          .catch((error) => {
            console.log("Error importing league to algolia", error);
          });
      });
  });

db.collection("Teams")
  .get()
  .then((snap) => {
    const records = [];
    for (var index in snap.docs) {
      var myDoc = snap.docs[index];
      var data = myDoc.data();
      data.objectID = "T" + myDoc.id;
      delete data.archived;
      delete data.admins;
      delete data.currentSeason;
      delete data.trackAttendence;
      delete data.arrivalTime;
      delete data.arriveEarly;
      data.searchRanking = 1000;
      records.push(data);
    }
    teamIndex
      .saveObjects(records)
      .then(() => {
        console.log("League imported to algolia");
      })
      .catch((error) => {
        console.log("Error importing league to algolia", error);
      });
  });
