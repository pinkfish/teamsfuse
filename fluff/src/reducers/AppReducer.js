import { combineReducers } from 'redux';
import UserReducer from './UserReducer';
import { firebaseStateReducer } from 'react-redux-firebase';
import { reducer as formReducer } from 'redux-form';
import { NavReducer } from './NavReducers';


export const makeRootReducer = (asyncReducers) => {
  return combineReducers({
      nav: UserReducer,
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
