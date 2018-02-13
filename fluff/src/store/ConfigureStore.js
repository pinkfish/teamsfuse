// Redux Store Configuration
import { applyMiddleware, compose, createStore } from 'redux';
import thunk from 'redux-thunk';
import makeRootReducer from '../reducers/AppReducer';
import RNFirebase from 'react-native-firebase';
import { getFirebase, reactReduxFirebase } from 'react-redux-firebase';

const reactNativeFirebaseConfig = {
    debug: true,
    enableRedirectHandling: false
};

const reduxFirebaseConfig = {
    userProfile: 'users', // save users profiles to 'users' collection,
    enableRedirectHandling: false
};

export default (initialState = { firebase: {} }) => {
 // initialize firebase
 const firebase = RNFirebase.initializeApp(reactNativeFirebaseConfig);

 const middleware = [
     // make getFirebase available in third argument of thunks
    thunk.withExtraArgument({ getFirebase }),
  ];

 const store = createStore(
   makeRootReducer(),
   initialState,
   compose(
     reactReduxFirebase(firebase, reduxFirebaseConfig),
     applyMiddleware(...middleware)
   )
 );

 return store;
};
