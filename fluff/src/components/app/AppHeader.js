import React, { Component } from "react";
import {
  Button,
  Container,
  Header,
  Title,
  Body,
  Icon,
  Left,
  Content,
  Right,
  Text
} from "native-base";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirebase } from 'react-redux-firebase';
import { withNavigation, HeaderBackButton} from 'react-navigation';


export class AppHeaderLeftInternal extends Component {
  render() {
    return (
          <Button
            transparent
            onPress={() => this.props.navigation.navigate('DrawerToggle') }
          >
            <Icon name="menu" />
          </Button>
    );
  }
}

export const AppHeaderLeft = withNavigation(AppHeaderLeftInternal);

const enhance = compose(
  connect(({ firebase: { auth, profile } }) => ({
    auth: auth,
    profile: profile
  })),
  withNavigation,
  withFirebase
  );


export class AppHeaderRightInternal extends Component {
  loginOrProfile = (auth, nav) => {
    if (isEmpty(auth)) {
      nav.navigate('UserLogin');
    } else {
      nav.navigate('Profile');
    }
  }
  render() {
    return (
      <Button
        transparent
        onPress={() => this.loginOrProfile(this.props.auth, this.props.navigation)  }
      >
        <Icon name={isEmpty(this.props.auth) ? "ios-images" : "ios-images-outline" } />
      </Button>
    );
  }
}

export const AppHeaderRight = enhance(AppHeaderRightInternal);

export class ModalHeaderInternal extends Component {
  render() {
    return (
      <Header>
        <Left>
          <Button transparent onPress={() => this.props.navigation.goBack() }>
            <Icon name="ios-arrow-back" />
          </Button>
        </Left>
        <Body>
          <Title>Header</Title>
        </Body>
        <Right></Right>
      </Header>);
  }
}

export const ModalHeader = withNavigation(ModalHeaderInternal);
export const FluffHeader = withNavigation(ModalHeaderInternal);
