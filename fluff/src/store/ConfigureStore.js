// Redux Store Configuration
import { applyMiddleware, compose, createStore } from 'redux';
import thunk from 'redux-thunk';
import makeRootReducer from '../reducers/AppReducer';
import RNFirebase from 'react-native-firebase';
import { getFirebase, reactReduxFirebase } from 'react-redux-firebase';
import { persistStore, persistCombineReducers, persistReducer } from 'redux-persist';
import { AsyncStorage } from 'react-native';
import { reduxFirestore } from 'redux-firestore';
import { createLogicMiddleware } from 'redux-logic';
import arrLogic from '../logic/logic';


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
  blacklist: [ 'form' ]
};


export default (initialState = { firebase: {}, firestore: {} }) => {
 console.log('Bing?');
 // initialize firebase
 const firebase = RNFirebase.initializeApp(reactNativeFirebaseConfig);
 firebase.firestore();
 const rootReducer = makeRootReducer();
 console.log(rootReducer);


 const persistedReducer = persistReducer(persistConfig, rootReducer);

 const deps = { // optional injected dependencies for logic
   // anything you need to have available in your logic
   firestore: firebase.firestore(),
   firebase: firebase
 };

 console.log('Logic', arrLogic, deps);
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
 const persistor = persistStore(store);
 console.log('Created store and persistor ', persistor, store);
 return { persistor, store };
};
