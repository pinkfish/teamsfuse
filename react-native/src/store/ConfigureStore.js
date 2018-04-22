// Redux Store Configuration
import { applyMiddleware, compose, createStore } from 'redux';
import thunk from 'redux-thunk';
import makeRootReducer from '../reducers/AppReducer';
import RNFirebase from 'react-native-firebase';
import { getFirebase, reactReduxFirebase } from 'react-redux-firebase';
import { persistStore, persistCombineReducers, persistReducer, createTransform } from 'redux-persist';
import { AsyncStorage } from 'react-native';
import { reduxFirestore } from 'redux-firestore';
import { createLogicMiddleware } from 'redux-logic';
import arrLogic from '../logic/logic';
import momenttz from 'moment-timezone';
import moment from 'moment';


const reactNativeFirebaseConfig = {
    debug: true,
    enableRedirectHandling: false
};

const reduxFirebaseConfig = {
    userProfile: 'User', // save users profiles to 'users' collection,
    enableRedirectHandling: false,
    useFirestoreForProfile: true
};

const persistConfig = {
  key: 'root',
  storage: AsyncStorage,
  blacklist: [ 'form', 'firebase', 'firestore' ],
  transforms: [ ],
  debug: true
};

export default (initialState = { firebase: {}, firestore: {} }) => {
 // initialize firebase
 const firebase = RNFirebase.initializeApp(reactNativeFirebaseConfig);
 firebase.firestore();
 const rootReducer = makeRootReducer();

 const persistedReducer = persistReducer(persistConfig, rootReducer);

 const deps = { // optional injected dependencies for logic
   // anything you need to have available in your logic
   firestore: firebase.firestore(),
   firebase: firebase
 };

 const logicMiddleware = createLogicMiddleware(arrLogic, deps);

 const middleware = [
     // make getFirebase available in third argument of thunks
    thunk.withExtraArgument({ getFirebase }),
    logicMiddleware
  ];

 const store = createStore(
   persistedReducer,
   initialState,
   compose(
     reactReduxFirebase(firebase, reduxFirebaseConfig),
     reduxFirestore(firebase),
     applyMiddleware(...middleware)
   )
 );
 const persistor = persistStore(store, null, () => console.log('callback'));
 return { persistor, store };
};
