import React, { Component } from "react";
import { Root, StyleProvider, Text } from "native-base";
import { StackNavigator } from "react-navigation";

import Home from "../home/Home";
import AppDrawer from "./AppDrawer";
import { AppHeaderLeft, AppHeaderRight } from "./AppHeader";

const AppNavigator = StackNavigator(
  {
    Home: { screen: Home },
    Drawer: { screen: AppDrawer },
  },
  {
    initialRouteName: "Drawer",
    headerMode: "float",
    /* The header config from HomeScreen is now here */
    navigationOptions: ({navigation}) => ({
      headerStyle: {
        backgroundColor: '#f4511e',
      },
      headerTintColor: '#fff',
      title: 'Team Fuse',
      headerTitleStyle: {
        fontWeight: 'bold',
      },
      headerLeft: <AppHeaderLeft />,
      headerRight: <AppHeaderRight />
    })
  },
);

export default AppNavigator;
