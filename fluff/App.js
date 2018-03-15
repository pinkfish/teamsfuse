import React from "react";
import AppBase from "./src/components/app/AppBase";
import AppReducer from './src/reducers/AppReducer';
import ConfigureStore from './src/store/ConfigureStore';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react'
import { Text } from "native-base";
import { MenuProvider } from 'react-native-popup-menu';
import Loading from "./src/components/app/Loading";


import { createStore } from 'redux';

const { persistor, store } = ConfigureStore({});

export default class App extends React.Component {
  render() {
    return <Provider store={store}>
             <PersistGate loading={<Loading />} persistor={persistor}>
               <MenuProvider>
                 <AppBase persistor={persistor} />
               </MenuProvider>
            </PersistGate>
          </Provider>;
  }
}
