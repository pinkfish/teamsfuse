import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import { DrawerNavigator } from "react-navigation";

import SideBar from "../sidebar/SideBar";
import Home from "../home/Home";

const Drawer = DrawerNavigator(
    {
      Home: { screen: Home },
    },
    {
      contentComponent: props => <SideBar {...props} />,
      initialRouteName: "Home",
    });

export default Drawer;
