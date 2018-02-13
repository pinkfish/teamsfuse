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
import { isLoaded, isEmpty, firebaseConnect } from 'react-redux-firebase';
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
  connect(({ firebase: { auth } }) => ({
    uid: auth.uid
  })),
  withNavigation
  );


export class AppHeaderRightInternal extends Component {
  render() {
    return (
      <Button
        transparent
        onPress={() => this.props.navigation.navigate('Profile') }
      >
        <Icon name="ios-images" />
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
