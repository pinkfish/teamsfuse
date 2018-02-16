import { combineReducers } from 'redux';
import { firebaseStateReducer } from 'react-redux-firebase';
import { reducer as formReducer } from 'redux-form';
import { TeamsReducer } from './TeamsReducer'
import { NavReducer } from './NavReducers';


export const makeRootReducer = (asyncReducers) => {
  return combineReducers({
      firebase: firebaseStateReducer,
      form: formReducer,
      nav: NavReducer,
      ...asyncReducers
    });
}

export default makeRootReducer;

// Useful for injecting reducers as part of async routes
export const injectReducer = (store, { key, reducer }) => {
  store.asyncReducers[key] = reducer
  store.replaceReducer(makeRootReducer(store.asyncReducers))
}
