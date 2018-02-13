import React, { Component } from "react";
import { Root, StyleProvider, StatusBar } from "native-base";
import getTheme from "../../theme/components";
import variables from "../../theme/variables/commonColor";
import { connect } from 'react-redux'

import ModalNavigator from "./ModalNavigator";

export default () =>
    <StyleProvider style={getTheme(variables)}>
      <Root>
        <ModalNavigator />
      </Root>
    </StyleProvider>;
