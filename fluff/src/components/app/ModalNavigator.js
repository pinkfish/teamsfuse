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
import AddTeam from "../team/AddTeam";
import AddGame from "../games/AddGame";

const ModalNavigator = StackNavigator(
  {
    Main: { screen: AppNavigator },
    UserLogin: { screen: UserLogin },
    Settings : { screen: Settings },
    Profile: { screen: Profile },
    EditProfile: { screen: EditProfile },
    OpponentList: { screen: OpponentList },
    EditOpponent: { screen: EditOpponent },
    EditTeam: { screen: EditTeam },
    AddGame: { screen: AddGame },
    AddTeam: { screen: AddTeam },
  },
  {
    mode: 'modal',
    initialRouteMode: 'Main',
    headerMode: 'none',
  }
);

export default ModalNavigator;
