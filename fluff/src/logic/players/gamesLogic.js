import { createLogic } from 'redux-logic';
import {
  FETCH_GAME_DATA,
  CANCEL_FETCH_GAME_DATA,
  fetchGameDataFailure,
  fetchGameDataSuccess,
  fetchGameDataAdd,
  fetchGameDataUpdate,
  fetchGameDataDelete,
  fetchGameData
} from '../../actions/Games';
import {
  FETCH_TEAM_DATA_ADD,
  FETCH_TEAM_DATA_DELETE,
  FETCH_TEAM_DATA_SUCCESS
} from '../../actions/Teams';

function teamOnSnapshot(querySnapshot, dispatch) {
  querySnapshot.docChanges.forEach((change) => {
    var team = change.doc.data();
    team.uid = change.doc.id;
    if (change.type === "added") {
      dispatch(fetchGameDataAdd(team));
    }
    if (change.type === "modified") {
      dispatch(fetchGameDataUpdate(team));
    }
    if (change.type === "removed") {
      dispatch(fetchGameDataDelete(team));
    }
  });
}

const fetchGamesLogic = createLogic({
  type: FETCH_GAME_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_GAME_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Go through all the players and get their teams.
    const teams = getState().teams.list;
    teamsColl = firestore.collection('Teams');
    allGames= {};
    allPromises = [];
    for (key in teams) {
      team = teams[key];
      if (teams.hasOwnProperty(key)) {
        teamQuery = teamsColl.doc(team.uid).collection('Games')
            .orderBy("gameTime");
        team.snapshotListen = teamQuery.onSnapshot(function(querySnapshot) {
          teamOnSnapshot(querySnapshot, dispatch);
        });
        teamPromise = teamQuery.get()
            .then(function(querySnapshot) {
              // Got all the teams.  Yay!
              querySnapshot.forEach(gameDoc => {
                var game = gameDoc.data();
                game.uid = gameDoc.id;
                game.teamUid = team.uid;
                allGames[game.uid] = game;
            })
          });
        allPromises.push(teamPromise);
      }
    }
    Promise.all(allPromises)
       .then(function(values) {
         // All done, sent the messages.
         dispatch(fetchGameDataSuccess(allGames));
         done();
       })
       .catch(function(error) {
         console.log('Error fetching games', error);
         dispatch(fetchGameDataFailure());
         done();
       });
  }
});


// Handle updateing the unsubscribe/unsubscribe on delete/addr
const addTeamLogic = createLogic({
  type: FETCH_TEAM_DATA_ADD,
  cancelType: CANCEL_FETCH_GAME_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    teamsColl = firestore.collection('Teams');
    teamQuery = teamsColl.doc(action.payload.uid).collection('Games')
        .orderBy("gameTime");
    action.payload.snapshotListen = teamQuery.onSnapshot(function(querySnapshot) {
      teamOnSnapshot(querySnapshot, dispatch);
    });
    done();
  }
});

// Handle updateing the unsubscribe/unsubscribe on delete/addr
const deleteTeamLogic = createLogic({
  type: FETCH_TEAM_DATA_DELETE,
  cancelType: CANCEL_FETCH_GAME_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Find the player in the storage.
    teams = getState().teams.list;
    teams.forEach(team => {
      if (team.uid == action.payload.uid) {
        if (team.snapshotListen) {
          console.log('Not listening to this any more', player.uid);
          team.snapshotListen();
          team.snapshotListen = null;
        }
      }
    });
    done();
  }
});

const teamsLoadSuccessLogic = createLogic({
  type: FETCH_TEAM_DATA_SUCCESS,
  cancelType: CANCEL_FETCH_GAME_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // dispatch a request to get the team data too.
    dispatch(fetchGameData());
    done();
  }
})

export default [
  fetchGamesLogic,
  addTeamLogic,
  deleteTeamLogic,
  teamsLoadSuccessLogic
];
