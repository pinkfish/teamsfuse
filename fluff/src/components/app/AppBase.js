import React, { Component } from "react";
import { Root, StyleProvider, StatusBar } from "native-base";
import getTheme from "../../theme/components";
import material from "../../theme/variables/material";
import { connect } from 'react-redux'

import ModalNavigator from "./ModalNavigator";

export default () =>
    <StyleProvider style={getTheme(material)}>
      <Root>
        <ModalNavigator />
      </Root>
    </StyleProvider>;
