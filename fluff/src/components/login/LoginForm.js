
import React, { Component } from "react";
import { View, Image } from 'react-native';
import { Field, reduxForm } from 'redux-form'
import I18n from '../../../i18n/I18n';
import { isLoaded, isEmpty, firebaseConnect, withFirestore } from 'react-redux-firebase';
import {
  Container,
  Header,
  Title,
  Content,
  Button,
  Footer,
  Item,
  Label,
  Input,
  Body,
  Left,
  Right,
  Icon,
  Form,
  Text,
  TextInput,
  ListItem
} from "native-base";
import styles from "./styles";
import MyTextInput from "../utils/MyTextInput";
import { withNavigation } from 'react-navigation';

const renderInput = ({ input: { onChange, ...restInput }}) => {
  return <Input style={styles.input} onChangeText={(value) => { onChange(value);  }} {...restInput} />
}


class LoginFormView extends Component {
  constructor(props, context) {
    super(props, context);
    this.onSubmit = this.onSubmit.bind(this);
    this.state = {
         errorText: ''
    }
  }

  onSubmit = (values, dispatch) => {
    return new Promise((resolve, reject) => {
      this.props.firebase.login({ email : values.email, password: values.password })
            .then((cred) => {
              resolve();
              this.navigation.navigate.goBack();
            })
            .catch((error) => {
              // Update the field with an error string.
              this.setState({errorText: error.message});
              resolve();
            })
          });
  }

  handleForgotPassword = () => {
    this.props.navigation.navigate('ForgotPassword')
  }

  handleSignUp = () => {
    this.props.navigation.navigate('SignUp')
  }

  handleVerify = () => {
    this.props.navigation.navigate('VerifyEmail')
  }

  render() {
    const { handleSubmit, submitting } = this.props

    const formStates = ['asyncValidating', 'dirty', 'pristine', 'valid', 'invalid', 'submitting',
    'submitSucceeded', 'submitFailed'];

    return (
        <Content padder>
          <Image source={require('../../../assets/loginlogo.png')} />
          <Field name="email" placeholder={I18n.t('email')} component={MyTextInput} regular first />

          <Field name="password" placeholder={I18n.t('password')} component={MyTextInput} regular last secureTextEntry />
          <Text>{this.state.errorText}</Text>

          <Button block primary style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSubmit)} >
            <Text>{I18n.t('signin')}</Text>
          </Button>

          <View style={styles.extrabuttons}>
            <Button  transparent onPress={this.handleForgotPassword} >
              <Text>{I18n.t('forgotpassword')}</Text>
            </Button>
            <Button transparent onPress={this.handleSignUp} >
              <Text>{I18n.t('signup')}</Text>
            </Button>
            <Button transparent onPress={this.handleVerify} >
              <Text>{I18n.t('verifyemail')}</Text>
            </Button>
          </View>
        </Content>
    );
  }
};

export default reduxForm({
  form: 'Login',
  onSubmit: values => {

  },
  validate: values => {
    const errors = {}

    if (!values.email) {
      errors.email = I18n.t('needemail')
    }

    if (!values.password) {
      errors.password = I18n.t('needpassword')
    }

    // Do the actual login here.
    return errors
  }
})(withFirestore(withNavigation(LoginFormView)))
