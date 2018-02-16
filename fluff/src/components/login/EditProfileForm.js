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
      this.props.firebase.updateAuth({
        displayName : values.name,
        phoneNumber: values.phone })
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
    name = this.props.auth.displayName;
    if (!name) {
      name = '';
    }
    phone = this.props.auth.phoneNumber;
    if (!phone) {
      phone = '';
    }
    console.log('stuff ', name, phone)
    return (
      <Content style={{ flex: 1, backgroundColor: "#fff", top: -1 }}>
        <ListItem style={styles.container}>
          <Thumbnail source={this.props.auth.photoURL ? {uri: this.props.auth.photoURL} : camera }
              style={{width: 100, height: 100}} />
          <Body>
            <Field name="name" title={I18n.t('name')} component={MyTextInput} defaultValue={name} floatingLabel />
            <Field name="phone" title={I18n.t('phonenumber')} component={MyTextInput} defaultValue={phone} secureTextEntry floatingLabel last/>
            <Text>{this.state.errorText}</Text>
          </Body>
        </ListItem>
      </Content>
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
  withFirestore,
  withNavigation,
  reduxForm({
    form: 'EditProfile',
    onSubmit: values => {
    },
  })
  );


export default enhance(EditProfileForm);
