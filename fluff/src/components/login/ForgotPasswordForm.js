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


const camera = require("../../../assets/camera.png");

class EditProfileForm extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  mySubmitCheck = (values, dispatch) => {
    console.log('mySubmitCheck', values, this.props.auth);
    return new Promise((resolve, reject) => {
      this.props.firebase.forgotpassword({ email: values.email});
      });
  }


  render() {
    const { auth } = this.props;

    console.log('props', this.props);

    return (
      <Content style={{ flex: 1, backgroundColor: "#fff" }}>
        <Body>
          <Field name="email" title={I18n.t('email')} component={MyTextInput} floatingLabel />
          <Text>{this.state.errorText}</Text>
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
    form: 'ForgotPassword',
    enableReinitialize: true,
    onSubmit: values => {
    },
  })
  );


export default enhance(EditProfileForm);
