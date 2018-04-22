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

  componentDidMount() {
    this.props.onMyFormRef(this)
  }

  componentWillUnmount() {
    this.props.onMyFormRef(undefined)
  }

  doSubmit = () =>{
    this.props.handleSubmit(this.mySubmitCheck)();
  }

  mySubmitCheck = (values, dispatch) => {
    console.log('mySubmitCheck', values, this.props.auth);
    return new Promise((resolve, reject) => {
      this.props.firebase.updateProfile({
        displayName : values.displayName,
        phoneNumber: values.phoneNumber })
            .then((cred) => {
              this.props.firebase.reloadAuth().
                 then((cred) => {
                    resolve();
                    console.log('Submit done ', this.props.auth);
                     this.props.navigation.goBack();
                 })
                 .catch((error) => {
                   // Update the field with an error string.
                   this.setState({errorText: error.message});
                   resolve();
                 })
            })
            .catch((error) => {
              // Update the field with an error string.
              this.setState({errorText: error.message});
              resolve();
            })
          });
  }


  render() {
    const { auth, profile } = this.props;

    console.log('props', this.props);

    return (
      <Content padder>
        <Item>
          <Thumbnail source={auth.photoURL ? {uri: auth.photoURL} : camera }
              style={{width: 100, height: 100}} />
          <Body>
            <Field name="displayName" placeholder={I18n.t('name')} component={MyTextInput} defaultValue={profile.displayName} regular first />
            <Field name="phoneNumber" placeholder={I18n.t('phonenumber')} component={MyTextInput} defaultValue={profile.phoneNumber} regular last/>
            <Text>{this.state.errorText}</Text>
          </Body>
        </Item>
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
    form: 'EditProfile',
    enableReinitialize: true,
    onSubmit: values => {
    },
  })
  );


export default enhance(EditProfileForm);
