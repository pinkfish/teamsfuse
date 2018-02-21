import { createLogic } from 'redux-logic';
import {
  FETCH_PLAYER_DATA,
  CANCEL_FETCH_PLAYER_DATA,
  fetchPlayerDataFailure,
  fetchPlayerDataSuccess,
  fetchPlayerDataAdd,
  fetchPlayerDataUpdate,
  fetchPlayerDataDelete,
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
    playerQuery = firestore.collection('Players')
        .where('user.' + auth.uid + '.added', '==', true);
    player.snapshotListen = playerquery.onSnapshot(function(querySnapshot) {
          querySnapshot.docChanges.forEach((change) => {
            var player = doc.data();
            player.uid = doc.id;
            if (change.type === "added") {
              dispatch(fetchPlayerDataAdd(team));
            }
            if (change.type === "modified") {
              dispatch(fetchPlayerDataUpdate(team));
            }
            if (change.type === "removed") {
              dispatch(fetchPlayerDataDelete(team));
            }
        });
      });
    playerQuery.get()
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
                  })
                  console.log('all done', promises)
                  dispatch(fetchPlayerDataSuccess(allPlayers));
                  done();
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
