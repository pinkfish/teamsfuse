import React from "react";
import Setup from "./src/boot/setup";
import AppReducer from './src/reducers/AppReducer';
import { Provider } from 'react-redux';

import { createStore } from 'redux';


export default class App extends React.Component {
  store = createStore(AppReducer);
  render() {

    return <Provider store=store>
      <Setup />
    </Provider>;
  }
}
