import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import { StackNavigator,  } from "react-navigation";
import I18n from '../../../i18n/I18n';


import Home from "../home/Home";
import AppNavigator from "./AppNavigator";
import UserLogin from '../login/UserLogin';
import ForgotPassword from '../login/ForgotPassword';
import VerifyEmail from '../login/VerifyEmail';
import Settings from "../settings/Settings";
import Profile from "../login/Profile";
import EditProfile from "../login/EditProfile";
import OpponentList from "../opponent/OpponentList";
import EditOpponent from "../opponent/EditOpponent";
import EditTeam from "../team/EditTeam";
import SignUp from "../login/SignUp";

const routes =   {
    SignIn: {
      screen: UserLogin,
      navigationOptions: {
        title: I18n.t('signin')
      }
    },
    SignUp: {
      screen: SignUp,
      navigationOptions: {
        title: I18n.t('signup')
      }
    },
    VerifyEmail: {
      screen: VerifyEmail,
      navigationOptions: {
        title: I18n.t('verifyemail')
      }
    },
    ForgotPassword: {
      screen: ForgotPassword,
      navigationOptions: {
        title: I18n.t('forgotpassword')
      }
    }
  };

export const SignedOutNavigator = StackNavigator(
  routes,
  {
    mode: 'modal',
    initialRouteName: 'SignIn',
  }
);

export const VerifyEmailNavigator = StackNavigator(
  routes,
  {
    mode: 'modal',
    initialRouteName: 'VerifyEmail',
  }
);
