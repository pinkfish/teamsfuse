import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import { StackNavigator,  } from "react-navigation";

import Home from "../home/Home";
import AppNavigator from "./AppNavigator";
import UserLogin from '../login/UserLogin';
import Settings from "../settings/Settings";
import Profile from "../login/Profile";
import EditProfile from "../login/EditProfile";
import OpponentList from "../opponent/OpponentList";
import EditOpponent from "../opponent/EditOpponent";
import EditTeam from "../team/EditTeam";
import SignUp from "../login/SignUp";

const ModalNavigator = StackNavigator(
  {
    SignIn: {
      screen: UserLogin,
      navigationOptions: {
        title: 'Sign In'
      }
    },
    SignUp: {
      screen: SignUp,
      navigationOptions: {
        title: 'Sign Up'
      }
    },
  },
  {
    mode: 'modal',
    initialRouteMode: 'UserLogin',
  }
);

export default ModalNavigator;
