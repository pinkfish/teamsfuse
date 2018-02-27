import { createLogic } from 'redux-logic';
import {
  FETCH_TEAM_DATA,
  CANCEL_FETCH_TEAM_DATA,
  fetchTeamDataFailure,
  fetchTeamDataSuccess,
  fetchTeamDataAdd,
  fetchTeamDataDelete,
  fetchTeamDataUpdate,
  fetchTeamData
} from '../../actions/Teams.js';
import {
  FETCH_PLAYER_DATA_ADD,
  FETCH_PLAYER_DATA_DELETE,
  FETCH_PLAYER_DATA_SUCCESS,
} from '../../actions/Players.js';
import momenttz from 'moment-timezone';
import moment from 'moment';


function playerOnSnapshot(querySnapshot, dispatch) {
  querySnapshot.docChanges.forEach((change) => {
    var team = change.doc.data();
    team.uid = change.doc.id;
    team.displayTime = moment(team.time).tz(team.timezone);
    if (change.type === "added") {
      dispatch(fetchTeamDataAdd(team));
    }
    if (change.type === "modified") {
      dispatch(fetchTeamDataUpdate(team));
    }
    if (change.type === "removed") {
      dispatch(fetchTeamDataDelete(team));
    }
  });
}

const fetchTeamsLogic = createLogic({
  type: FETCH_TEAM_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_TEAM_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Go through all the players and get their teams.
    const players = getState().players.list;
    teamsColl = firestore.collection('Teams');
    allTeams = {};
    allPromises = [];
    for(var key in players) {
      player = players[key];
      if (players.hasOwnProperty(key)) {
        playerquery = teamsColl.where('player.' + player.uid + '.added', '==', true)
        // Track changes to this query too.
        player.snapshotListen = playerquery.onSnapshot(function(querySnapshot) {
          playerOnSnapshot(querySnapshot, dispatch);
        });
        playerPromise = playerquery.get()
          .then(function(querySnapshot) {
            // Got all the teams.  Yay!
            querySnapshot.forEach(doc => {
              var team = doc.data();
              team.uid = doc.id;
              // Make sure we track how we got in here.
              if (allTeams.hasOwnProperty(team.uid)) {
                team.myPlayerId = allTeams[team.uid].myPlayerId;
                team.myPlayerId.push(player.uid);
              }
              team.displayTime = moment(team.time).tz(team.timezone);
              allTeams[team.uid] = team;
            });
          });
        allPromises.push(playerPromise);
        // Do onSnapshot updates.
      }
    }
    Promise.all(allPromises)
       .then(function(values) {
         // All done, sent the messages.
         dispatch(fetchTeamDataSuccess(allTeams));
         done();
       })
       .catch(function(error) {
         console.log('Error fetching teams', error);
         dispatch(fetchTeamDataFailure());
         done();
       })
  }
});

// Handle updateing the unsubscribe/unsubscribe on delete/addr
const addPlayerLogic = createLogic({
  type: FETCH_PLAYER_DATA_ADD,
  cancelType: CANCEL_FETCH_TEAM_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    teamsColl = firestore.collection('Teams');
    playerquery = teamsColl.where('player.' + action.payload.uid + '.added', '==', true)
    action.payload.snapshotListen = playerquery.onSnapshot(function(querySnapshot) {
      playerOnSnapshot(querySnapshot, dispatch);
    });
    done();
  }
});

// Handle updateing the unsubscribe/unsubscribe on delete/addr
const deletePlayerLogic = createLogic({
  type: FETCH_PLAYER_DATA_DELETE,
  cancelType: CANCEL_FETCH_TEAM_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Find the player in the storage.
    players = getState().players.list;
    players.forEach(player => {
      if (player.uid == action.payload.uid) {
        if (player.snapshotListen) {
          player.snapshotListen();
          player.snapshotListen = null;
        }
      }
    });
    done();
  }
});

const playerLoadSuccessLogic = createLogic({
  type: FETCH_PLAYER_DATA_SUCCESS,
  cancelType: CANCEL_FETCH_TEAM_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // dispatch a request to get the team data too.
    dispatch(fetchTeamData());
    done();
  }
})

export default [
  fetchTeamsLogic,
  addPlayerLogic,
  deletePlayerLogic,
  playerLoadSuccessLogic
];
