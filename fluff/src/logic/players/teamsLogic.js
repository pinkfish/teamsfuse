import { createLogic } from 'redux-logic';
import {
  FETCH_TEAM_DATA,
  CANCEL_FETCH_TEAM_DATA,
  fetchTeamDataFailure,
  fetchTeamDataSuccess
} from '../../actions/Teams.js';

const fetchTeamsLogic = createLogic({
  type: FETCH_TEAM_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_TEAM_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Go through all the players and get their teams.
    const players = getState().players.list;
    teamsColl = firestore.collection('Teams');
    allTeams = [];
    allGames= [];
    allPromises = [];
    players.forEach(player => {
      playerPromise = teamsColl.where('player.' + player.uid + '.added', '==', true)
          .get()
              .then(function(querySnapshot) {
                // Got all the teams.  Yay!
                querySnapshot.forEach(doc => {
                  console.log("team", doc);
                  var team = doc.data();
                  team.uid = doc.id;
                  // Make sure we track how we got in here.
                  team.myPlayerId = player.uid;
                  allTeams.push(team);
                });
              });
      allPromises.push(playerPromise);
    });
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

export default [
  fetchTeamsLogic
];
