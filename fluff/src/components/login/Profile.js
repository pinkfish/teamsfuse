import React, { Component } from "react";
import { Content, Card, CardItem, Text, Body, Container } from "native-base";
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirebase, login, logout } from 'react-redux-firebase';
import {
  Button,
  Header,
  Title,
  Icon,
  Left,
  Right,
} from "native-base";
import { Image } from 'react-native';

const camera = require("../../../assets/camera.png");

class Profile extends Component {
  render() {
    return (
      <Container>
        <ModalHeader />
        <Content padder>
          <Card>
            <CardItem>
              <Image source={camera} />
            </CardItem>
            <CardItem>
              <Header>
                <Text>{I18n.t('name')}</Text>
              </Header>
              <Body>
                <Text>{this.props.auth.displayName ? this.props.auth.displayName : I18n.t('unknown')}</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Header>
                <Text>{I18n.t('email')}</Text>
              </Header>
              <Body>
                <Text>{this.props.auth.email}</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Header>
                <Text>{I18n.t('phonenumber')}</Text>
              </Header>
              <Body>
                <Text>
                  {this.props.auth.phoneNumber ? this.props.auth.phoneNumber : I18n.t('unknown')}
                </Text>
              </Body>
            </CardItem>
          </Card>
        </Content>
      </Container>

    );
  }
}

const enhance = compose(
  connect(
  // Map redux state to component props
  ({ firebase: { auth, profile } }) => ({
    auth,
    profile
  })),
  withFirebase
  );


export default enhance(Profile);
