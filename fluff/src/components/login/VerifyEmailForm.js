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
import { Field, reduxForm, submit } from 'redux-form'
import MyTextInput from "../utils/MyTextInput";
import { withNavigation } from 'react-navigation';
import RNFirebase from 'react-native-firebase';


const camera = require("../../../assets/camera.png");

class VerifyEmailForm extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  mySubmitCheck = (values, dispatch) => {
    console.log('mySubmitCheck', values, this.props.auth);
    this.props.firebase.reloadAuth();
    return new Promise((resolve, reject) => {
      this.props.firebase.verifyPasswordResetCode({ code: values.code});
      });
  }

  onSignout = () => {
    this.props.auth.logout();
  }

  onResendVerify = () => {
    this.props.firebase.reloadAuth();
    RNFirebase.auth().currentUser.sendEmailVerification();
  }


  render() {
    const { auth, handleSubmit } = this.props;

    console.log('props', this.props);

    return (
      <Content style={{ flex: 1, backgroundColor: "#fff" }}>
        <Body>
          <Field name="code" title={I18n.t('verifycode')} component={MyTextInput} floatingLabel />
          <Text>{this.state.errorText}</Text>
          <Button block primary style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSubmit)} >
            <Text>{I18n.t('verifyemail')}</Text>
          </Button>
          <Button block light style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onResendVerify)} >
            <Text>{I18n.t('resendverifyemail')}</Text>
          </Button>
          <Button block light style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSignout)} >
            <Text>{I18n.t('logout')}</Text>
          </Button>
        </Body>
      </Content>
    );
  }
}

const enhance = compose(
  connect(({ firebase: { auth, profile } }) => ({
    auth : auth,
    profile : profile,
    initialValues : auth
  })),
  withFirestore,
  withNavigation,
  reduxForm({
    form: 'VerifyEmail',
    enableReinitialize: true,
    onSubmit: values => {
    },
  })
  );


export default enhance(VerifyEmailForm);
