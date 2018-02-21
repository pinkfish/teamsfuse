import { createLogic } from 'redux-logic';
import {
  FETCH_PLAYER_DATA,
  CANCEL_FETCH_PLAYER_DATA,
  fetchPlayerDataFailure,
  fetchPlayerDataSuccess
} from '../../actions/Players.js';

const fetchTeamsLogic = createLogic({
  type: FETCH_PLAYER_DATA, // only apply this logic to this type
  cancelType: CANCEL_FETCH_PLAYER_DATA, // cancel on this type
  latest: true, // only take latest
  debounce: 500, /* ms */
  process({ firebase, firestore, getState, action }, dispatch, done) {

    console.log('fetch', getState());
    auth = getState().firebase.auth;
    // Get the players first.
    firestore.collection('Players')
        .where('user.' + auth.uid + '.added', '==', true)
        .get()
            .then(function(querySnapshot) {
                promises = []
                allPlayers = []
                if (querySnapshot.empty) {
                  console.log('No players, making one for me');
                  firestore.collection('Players').add( {
                    name: auth.displayName,
                    user: {
                      [auth.uid]: {
                        added: true,
                        relationship: 'me'
                      }
                    }
                  }).then(documentReference => {
                    console.log(`Added document with name: ${documentReference}`);
                    dispatch(fetchPlayerDataSuccess([documentReference]));
                    done();
                  }).catch(error => {
                    console.log('Error adding', error);
                    dispatch(fetchPlayerDataFailure());
                    done();
                  })
                } else {
                  allPlayers = []
                  querySnapshot.forEach(doc => {
                    console.log("player", doc);
                    var player = doc.data();
                    player.teams = [];
                    player.uid = doc.id;
                    allPlayers.push(player);
                    var dbRef = firestore.collection("Teams")
                        .where('player.' + player.uid + '.active', '==', true)
                        .get();
                    added = dbRef.then(function(querySnapshot) {
                      querySnapshot.forEach(teamDoc => {
                        console.log("Add parent");
                        player.teams.push(teamDoc.data());
                      });
                    });
                    promises.push(added);
                  })
                  Promise.all(promises)
                      .then(function(values) {
                        console.log('all done', promises)
                        dispatch(fetchPlayerDataSuccess(allPlayers));
                        done();
                      })
                      .catch(function(error) {
                        console.log('all errors', error)
                        dispatch(fetchPlayerDataFailure());
                        done();
                      });
                }
              })
              .catch(function(error) {
                console.log('fetch error', error)
                dispatch(fetchPlayerDataFailure());
                done();
              })

  }
});

export default [
  fetchTeamsLogic
];
