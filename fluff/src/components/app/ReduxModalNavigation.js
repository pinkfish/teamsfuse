import React, { Component } from "react";
import { Root, StyleProvider } from "native-base";
import * as ReactNavigation from 'react-navigation';
import getTheme from "../../theme/components";
import variables from "../../theme/variables/commonColor";
import { connect } from 'react-redux'

import ModalNavigator from "./ModalNavigator";

// here is our redux-aware our smart component
function ReduxModalNavigation (props) {
  const { dispatch, nav } = props
  const navigation = ReactNavigation.addNavigationHelpers({
    dispatch,
    state: nav
  })

  return <ModalNavigator navigation={navigation} />
}

const mapStateToProps = state => ({ nav: state.nav })
export default connect(mapStateToProps)(ReduxModalNavigation)
