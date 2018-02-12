import React from "react";
import Setup from "./src/boot/setup";
import AppReducer from './src/reducers/AppReducer';
import configureStore from './src/store/ConfigureStore';
import { Provider } from 'react-redux';

import { createStore } from 'redux';

const store = configureStore({});

export default class App extends React.Component {
  render() {

    return <Provider store={store}>
      <Setup />
    </Provider>;
  }
}
