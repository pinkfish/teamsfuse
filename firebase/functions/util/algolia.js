const algoliasearch = require("algoliasearch");
const functions = require("firebase-functions");
const algolia = algoliasearch(
  functions.config().algolia.appid,
  functions.config().algolia.key
);
const teamIndex = algolia.initIndex("teams");

exports.updateTeam = teamDoc => {
  var data = teamDoc.data();
  data.objectID = "T" + teamDoc.id;
  delete data.archived;
  delete data.admins;
  delete data.currentSeason;
  delete data.trackAttendence;
  delete data.arrivalTime;
  delete data.arriveEarly;
  data.searchRanking = 1000;
  teamIndex.saveObjects([data]);
};

exports.deleteTeam = teamId => {
  teamIndex.deleteObjects(["T" + teamId]);
};

exports.updateLeagueTeam = (db, teamDoc) => {
  var data = teamDoc.data();
  data.objectID = "t" + teamDoc.id;
  delete data.members;
  delete data.record;
  data.searchRanking = 500;
  // Update the data with fun.
  return db
    .collection("LeagueDivison")
    .doc(teamDoc.data().leagueDivisonUid)
    .get()
    .then(snap => {
      if (snap !== null && snap.exists) {
        data.leagueDivisonName = divisonData.name;
        data.leagueSeasonUid = divisonData.seasonUid;
        return db
          .collection("LeagueSeason")
          .doc(divisonData.seasonUid)
          .get();
      }
      return null;
    })
    .then(snap => {
      if (snap !== null && snap.exists) {
        var seasonData = snap.data();
        data.leagueSeasonName = seasonData.name;
        data.leagueUid = seasonData.leagueUid;
        return db
          .collection("League")
          .doc(divisonData.leagueUid)
          .get();
      }
      return null;
    })
    .then(snap => {
      if (snap !== null && snap.exists) {
        var leagueData = snap.data();
        data.leagueName = snap.name;
      }
      return teamIndex.saveObjects([data]);
    });
};

exports.deleteLeagueTeam = teamId => {
  teamIndex.deleteObjects(["t" + teamId]);
};

exports.deleteTeam = teamId => {
  teamIndex.deleteObjects(["T" + teamId]);
};

exports.updateLeague = leagueDoc => {
  var data = leagueDoc.data();
  data.objectID = "L" + leagueDoc.id;
  delete data.members;
  delete data.currentSeason;
  data.searchRanking = 900;
  records.push(data);
  index.browse(
    "",
    {
      filters: 'leagueUid="' + leagueDoc.id + '"',
      attributesToRetrieve: ["leagueDivisonName "]
    },
    (err, content) => {
      if (err) {
        throw err;
      }

      // Get the records to update.
      var toUpdateRecords = new Set();
      for (var i in content.hits) {
        var hit = content.hits[i];
        toUpdateRecords.add(hit.objectID);
      }
      var records = [];
      toUpdateRecords.forEach(id => {
        var data = { leagueDivisonName: leagueDoc.name, objectID: id };
        records.push(data);
      });
      teamIndex.partialUpdateObjects(records);
    }
  );
};

exports.delteLeague = teamId => {
  teamIndex.deleteObjects(["L" + teamId]);
};

exports.updateLeagueSeason = teamDoc => {
  index.browse(
    "",
    {
      filters: 'leagueSeasonUid="' + teamDoc.id + '"',
      attributesToRetrieve: ["leagueSeasonName "]
    },
    (err, content) => {
      if (err) {
        throw err;
      }

      // Get the records to update.
      var toUpdateRecords = new Set();
      for (var i in content.hits) {
        var hit = content.hits[i];
        toUpdateRecords.add(hit.objectID);
      }
      var records = [];
      toUpdateRecords.forEach(id => {
        var data = { leagueSeasonName: teamDoc.name, objectID: id };
        records.push(data);
      });
      teamIndex.partialUpdateObjects(records);
    }
  );
};

exports.deleteLeagueSeason = teamId => {};

exports.updateLeagueDivison = teamDoc => {
  index.browse(
    "",
    {
      filters: 'leagueDivisonUid="' + teamDoc.id + '"',
      attributesToRetrieve: ["leagueDivisonName "]
    },
    (err, content) => {
      if (err) {
        throw err;
      }

      // Get the records to update.
      var toUpdateRecords = new Set();
      for (var i in content.hits) {
        var hit = content.hits[i];
        toUpdateRecords.add(hit.objectID);
      }
      var records = [];
      toUpdateRecords.forEach(id => {
        var data = { leagueDivisonName: teamDoc.name, objectID: id };
        records.push(data);
      });
      teamIndex.partialUpdateObjects(records);
    }
  );
};

exports.deleteLeagueDivison = teamId => {};
