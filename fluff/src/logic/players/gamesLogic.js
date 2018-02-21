import { createLogic } from 'redux-logic';
import {
  FETCH_GAME_DATA,
  CANCEL_FETCH_GAME_DATA,
  fetchGameDataFailure,
  fetchGameDataSuccess
} from '../../actions/Games.js';

const fetchTeamsLogic = createLogic({
  type: FETCH_GAME_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_GAME_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {
    // Go through all the players and get their teams.
    const teams = getState().teams.list;
    teamsColl = firestore.collection('Teams');
    allGames= [];
    allPromises = [];
    teams.forEach(team => {
      teamPromise = teamsColl.doc(team.uid).collection('Games')
          .orderBy("gameTime")
          .get()
              .then(function(querySnapshot) {
                // Got all the teams.  Yay!
                querySnapshot.forEach(gameDoc => {
                  console.log("Add game");
                  var game = gameDoc.data();
                  game.uid = gameDoc.id;
                  allGames.push(gameDoc.data());
              })
            });
      allPromises.push(teamPromise);
    });
    Promise.all(allPromises)
       .then(function(values) {
         // All done, sent the messages.
         dispatch(fetchGameDataSuccess(allTeams));
         done();
       })
       .catch(function(error) {
         console.log('Error fetching games', error);
         dispatch(fetchGameDataFailure());
         done();
       });
  }
});

export default [
  fetchTeamsLogic
];
