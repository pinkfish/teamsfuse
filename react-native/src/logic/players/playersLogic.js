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
    auth = getState().firebase.auth;
    // Get the players first.
    playerQuery = firestore.collection('Players')
        .where('user.' + auth.uid + '.added', '==', true);
    result = {}
    result.snapshotListen = playerQuery.onSnapshot(function(querySnapshot) {
          querySnapshot.docChanges.forEach((change) => {
            var player = change.doc.data();
            player.uid = change.doc.id;
            update = {};
            update[player.uid] = player;
            if (change.type === "added") {
              dispatch(fetchPlayerDataAdd(update));
            }
            if (change.type === "modified") {
              dispatch(fetchPlayerDataUpdate(update));
            }
            if (change.type === "removed") {
              dispatch(fetchPlayerDataDelete(update));
            }
        });
      });
    playerQuery.get()
            .then(function(querySnapshot) {
                promises = []
                if (querySnapshot.empty) {
                  firestore.collection('Players').add( {
                    name: auth.displayName,
                    user: {
                      [auth.uid]: {
                        added: true,
                        relationship: 'me'
                      }
                    }
                  }).then(documentReference => {
                    data = documentReference.data();
                    data.uid = documentReference.id();
                    result.list = { };
                    result.list[data.uid] = data;
                    dispatch(fetchPlayerDataSuccess(result));
                    done();
                  }).catch(error => {
                    console.log('Error adding', error);
                    dispatch(fetchPlayerDataFailure());
                    done();
                  })
                } else {
                  allPlayers = {}
                  querySnapshot.forEach(doc => {
                    var player = doc.data();
                    player.teams = [];
                    player.uid = doc.id;
                    allPlayers[doc.id] = player;
                  })
                  result.list = allPlayers;
                  dispatch(fetchPlayerDataSuccess(result));
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
