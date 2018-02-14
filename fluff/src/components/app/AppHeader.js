import React, { Component } from "react";
import {
  Button,
  Container,
  Header,
  Title,
  Body,
  Left,
  Content,
  Right,
  Text
} from "native-base";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirebase } from 'react-redux-firebase';
import { withNavigation, HeaderBackButton} from 'react-navigation';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';


export class AppHeaderLeftInternal extends Component {
  render() {
    return (
          <Button
            transparent
            onPress={() => this.props.navigation.navigate('DrawerToggle') }
          >
            <Icon name="menu" size={25} />
          </Button>
    );
  }
}

export const AppHeaderLeft = withNavigation(AppHeaderLeftInternal);

const enhance = compose(
  connect(
  // Map redux state to component props
  ({ firebase: { auth, profile } }) => ({
    auth,
    profile
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
    console.log('auth ', this.props.auth, this.props.profile);

    if (isEmpty(this.props.auth)) {
       MyIcon = <Icon name="login" size={25} />;
    } else {
      if (this.props.auth.photoProfile) {
        MyIcon = <Thumbnail source={this.props.auth.photoProfile}  size={25} s/>
      } else {
        MyIcon = <Icon name="account-circle" size={25} />;
      }
    }

    return (
      <Button
        transparent
        onPress={() => this.loginOrProfile(this.props.auth, this.props.navigation)  }
      >
        {MyIcon}
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
            <Icon name="arrow-left" size={20} />
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
