import { createLogic } from 'redux-logic';
import {
  FETCH_OPPONENT_DATA,
  CANCEL_FETCH_OPPONENT_DATA,
  fetchOpponentDataFailure,
  fetchOpponentDataSuccess,
  fetchOpponentData
} from '../../actions/Opponents';
import {
  FETCH_TEAM_DATA_ADD,
  FETCH_TEAM_DATA_DELETE,
  FETCH_TEAM_DATA_SUCCESS
} from '../../actions/Teams';

function teamOnSnapshot(team, querySnapshot, dispatch) {
  allOpponents = {};
  querySnapshot.forEach((doc) => {
    var opponent = doc.data();
    opponent.uid = doc.id;
    allOpponents[doc.id] = opponent;
  });
  dispatch(fetchOpponentDataSuccess(team, allOpponents));
}

const fetchOpponentsLogic = createLogic({
  type: FETCH_OPPONENT_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_OPPONENT_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Go through all the players and get their teams.
    const teams = getState().teams.list;
    teamsColl = firestore.collection('Teams');
    allPromises = [];
    for (key in teams) {
      team = teams[key];
      if (teams.hasOwnProperty(key)) {
        teamQuery = teamsColl.doc(team.uid).collection('Opponents');
        team.snapshotListenOpponent = teamQuery.onSnapshot(function(querySnapshot) {
          teamOnSnapshot(team, querySnapshot, dispatch);
        });
        allOpponents = {};
        teamPromise = teamQuery.get()
                .then(function(querySnapshot) {
                  // Got all the teams.  Yay!
                  querySnapshot.forEach(opponentDoc => {
                    var opponent = opponentDoc.data();
                    opponent.uid = opponentDoc.id;
                    allOpponents[opponent.uid] = opponent;
                    var ignore = false;
                })
                dispatch(fetchOpponentDataSuccess(team, allOpponents));
              });
        allPromises.push(teamPromise);
      }
    }
    Promise.all(allPromises)
       .then(function(values) {
         // All done, sent the messages.
         done();
       })
       .catch(function(error) {
         console.log('Error fetching opponents', error);
         dispatch(fetchOpponentDataFailure());
         done();
       });
  }
});

// Handle updateing the unsubscribe/unsubscribe on delete/addr
const addTeamLogic = createLogic({
  type: FETCH_TEAM_DATA_ADD,
  cancelType: CANCEL_FETCH_OPPONENT_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    teamsColl = firestore.collection('Teams');
    teamQuery = teamsColl.doc(action.payload.uid).collection('Opponents');
    action.payload.snapshotListenOpponent = teamQuery.onSnapshot(function(querySnapshot) {
      teamOnSnapshot(action.payload, querySnapshot, dispatch);
    });
    done();
  }
});

// Handle updateing the unsubscribe/unsubscribe on delete/addr
const deleteTeamLogic = createLogic({
  type: FETCH_TEAM_DATA_DELETE,
  cancelType: CANCEL_FETCH_OPPONENT_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Find the player in the storage.
    teams = getState().teams.list;
    teams.forEach(team => {
      if (team.uid == action.payload.uid) {
        if (team.snapshotListenOpponent) {
          team.snapshotListenOpponent();
          team.snapshotListenOpponent = null;
        }
      }
    });
    done();
  }
});

const teamsLoadSuccessLogic = createLogic({
  type: FETCH_TEAM_DATA_SUCCESS,
  cancelType: CANCEL_FETCH_OPPONENT_DATA, // cancel on this type
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // dispatch a request to get the team data too.
    dispatch(fetchOpponentData());
    done();
  }
})

export default [
  fetchOpponentsLogic,
  addTeamLogic,
  deleteTeamLogic,
  teamsLoadSuccessLogic
];
