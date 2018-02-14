// Redux Store Configuration
import { applyMiddleware, compose, createStore } from 'redux';
import thunk from 'redux-thunk';
import makeRootReducer from '../reducers/AppReducer';
import RNFirebase from 'react-native-firebase';
import { getFirebase, reactReduxFirebase } from 'react-redux-firebase';
import { persistStore, persistCombineReducers, persistReducer } from 'redux-persist';
import { AsyncStorage } from 'react-native';


const reactNativeFirebaseConfig = {
    debug: true,
    enableRedirectHandling: false
};

const reduxFirebaseConfig = {
    userProfile: 'users', // save users profiles to 'users' collection,
    enableRedirectHandling: false
};

const persistConfig = {
  key: 'root',
  storage: AsyncStorage,
  blacklist: [ 'form' ]
};


export default (initialState = { firebase: {} }) => {
  console.log('Bing?');
 // initialize firebase
 const firebase = RNFirebase.initializeApp(reactNativeFirebaseConfig);
 const rootReducer = makeRootReducer();
 console.log(rootReducer);


 const persistedReducer = persistReducer(persistConfig, rootReducer);

 const middleware = [
     // make getFirebase available in third argument of thunks
    thunk.withExtraArgument({ getFirebase }),
  ];

 const store = createStore(
   persistedReducer,
   initialState,
   compose(
     reactReduxFirebase(firebase, reduxFirebaseConfig),
     applyMiddleware(...middleware)
   )
 );
 const persistor = persistStore(store);
 console.log('Created store and persistor ', persistor);
 return { persistor, store };
};
