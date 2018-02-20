import React, { Component } from "react";
import { Root, StyleProvider, StatusBar } from "native-base";
import getTheme from "../../theme/components";
import material from "../../theme/variables/material";
import { connect } from 'react-redux'

import NavigationSelector from "./NavigationSelector";


export default () =>
    <StyleProvider style={getTheme(material)}>
      <Root>
        <NavigationSelector />
      </Root>
    </StyleProvider>;
