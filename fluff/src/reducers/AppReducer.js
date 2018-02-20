import { combineReducers } from 'redux';
import { firebaseStateReducer } from 'react-redux-firebase';
import { reducer as formReducer } from 'redux-form';
import { CurrentTeamReducer } from './TeamsReducer';
import { NavReducer } from './NavReducers';
import { CurrentPlayerReducer } from './PlayerReducer';
import { firestoreReducer } from 'redux-firestore';
import { PlayerDataReducer } from './PlayerDataReducer';


export const makeRootReducer = (asyncReducers) => {
  return combineReducers({
      firebase: firebaseStateReducer,
      firestore: firestoreReducer,
      form: formReducer,
      nav: NavReducer,
      currentTeam: CurrentTeamReducer,
      currentPlayer: CurrentPlayerReducer,
      players: PlayerDataReducer,
      ...asyncReducers
    });
}

export default makeRootReducer;

// Useful for injecting reducers as part of async routes
export const injectReducer = (store, { key, reducer }) => {
  store.asyncReducers[key] = reducer
  store.replaceReducer(makeRootReducer(store.asyncReducers))
}
