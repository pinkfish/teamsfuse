import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirestore, login, logout } from 'react-redux-firebase';
import {
  Button,
  Header,
  Title,
  Item,
  Left,
  Right,
  Content,
  Card,
  CardItem,
  Text,
  Body,
  Container,
  Fab,
  List,
  ListItem,
  Thumbnail
} from "native-base";
import { Image } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';

const camera = require("../../../assets/camera.png");

class Profile extends Component {
  constructor(props, context) {
    super(props, context);
  }

  onPressItem = () => {
    this.props.navigation.navigate("EditProfile");
  };

  render() {
    const { auth } = this.props;
    return (
      <Container>
        <ModalHeader  title={I18n.t('profile')} />
        <Content style={{ flex: 1, backgroundColor: "#fff", top: -1 }}>
          <List>
            <ListItem style={styles.container}>
              <Thumbnail source={auth.photoURL ? {uri: auth.photoURL} : camera }
                    style={{width: 100, height: 100}} />
              <Body>
                <Text>{auth.displayName ? auth.displayName : I18n.t('unknown')}</Text>
                <Text>{auth.email}</Text>
              </Body>
            </ListItem>
            <ListItem style={styles.container}>
              <Body>
                <Text>
                  {auth.phoneNumber ? auth.phoneNumber : I18n.t('unknown')}
                </Text>
              </Body>
            </ListItem>
          </List>
        </Content>
        <Fab
            active={true}
            direction="up"
            containerStyle={{ }}
            style={{ backgroundColor: '#5067FF' }}
            position="bottomRight"
            onPress={() => this.onPressItem() }>
            <Icon name="account-edit" />
        </Fab>

      </Container>
    );
  }
}

const enhance = compose(
  firebaseConnect([ 'auth', 'profile']),
  connect(
  // Map redux state to component props
  ({ firebase: { auth, profile } }) => ({
    auth,
    profile
  })),
  );


export default enhance(Profile);
