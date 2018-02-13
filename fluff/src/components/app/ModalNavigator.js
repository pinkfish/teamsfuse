import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import { StackNavigator,  } from "react-navigation";

import Home from "../home/Home";
import AppNavigator from "./AppNavigator";
import UserLogin from '../login/UserLogin';
import Settings from "../settings/Settings";
import Profile from "../login/Profile";

const ModalNavigator = StackNavigator(
  {
    Main: { screen: AppNavigator },
    UserLogin: { screen: UserLogin },
    Settings : { screen: Settings },
    Profile: { screen: Profile },
  },
  {
    mode: 'modal',
    initialRouteMode: 'Main',
    headerMode: 'none',
  }
);

export default ModalNavigator;
