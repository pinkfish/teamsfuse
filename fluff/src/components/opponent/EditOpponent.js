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
import EditOpponentForm from './EditOpponentForm';
import { submit } from 'redux-form';

const camera = require("../../../assets/camera.png");

class EditOpponent extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  onPressItem = () => {
    // updater functions are preferred for transactional updates
    console.log(this.child);
    this.child.doSubmit();
  };

  render() {
    const { opponent, opponentId } = this.props

    return (
      <Container>
        <ModalHeader title={I18n.t('profile')} iconRight="check" onRightPress={this.onPressItem}/>

        <EditOpponentForm opponent={opponent} opponentId={opponentId} tonMyFormRef={(ref) => (this.child = ref)} />
      </Container>
    );
  }
}

export default connect()(EditOpponent);
