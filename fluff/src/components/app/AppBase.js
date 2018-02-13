import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import { StackNavigator, DrawerNavigator } from "react-navigation";
import getTheme from "../../theme/components";
import variables from "../../theme/variables/commonColor";

import SideBar from "../../screens/sidebar";

import UserLogin from '../login/UserLogin';

const Drawer = DrawerNavigator(
    {
      UserLogin: { screen: UserLogin }
    },
    {
      initialRouteName: "UserLogin",
      contentOptions: {
        activeTintColor: "#e91e63"
      },
      contentComponent: props => <SideBar {...props} />
    });

const AppNavigator = StackNavigator(
  {
    Drawer: { screen: Drawer },
  },
  {
    initialRouteName: "Drawer",
    headerMode: "none"
  }
);


export default () =>
    <StyleProvider style={getTheme(variables)}>
      <Root>
        <AppNavigator />
      </Root>
    </StyleProvider>;
