import { combineReducers } from 'redux';
import { firebaseStateReducer } from 'react-redux-firebase';
import { reducer as formReducer } from 'redux-form';
import { CurrentTeamReducer } from './TeamsReducer';
import { NavReducer } from './NavReducers';
import { firestoreReducer } from 'redux-firestore';


export const makeRootReducer = (asyncReducers) => {
  return combineReducers({
      firebase: firebaseStateReducer,
      firestore: firestoreReducer,
      form: formReducer,
      nav: NavReducer,
      currentTeam: CurrentTeamReducer,
      ...asyncReducers
    });
}

export default makeRootReducer;

// Useful for injecting reducers as part of async routes
export const injectReducer = (store, { key, reducer }) => {
  store.asyncReducers[key] = reducer
  store.replaceReducer(makeRootReducer(store.asyncReducers))
}
