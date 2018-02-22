
import React, { Component } from "react";
import { View, ScrollView } from 'react-native';
import { Field, reduxForm } from 'redux-form'
import I18n from '../../../i18n/I18n';
import { isLoaded, isEmpty, firebaseConnect, withFirestore } from 'react-redux-firebase';
import {
  Container,
  Header,
  Title,
  Content,
  Button,
  Item,
  Label,
  Input,
  Body,
  Left,
  Right,
  Icon,
  Form,
  Text,
  TextInput
} from "native-base";
import styles from "./styles";
import MyTextInput from "../utils/MyTextInput";
import { withNavigation } from 'react-navigation';

const renderInput = ({ input: { onChange, ...restInput }}) => {
  console.log("Rendering input");
  return <Input style={styles.input} onChangeText={(value) => { onChange(value); console.log("onChange<", value); }} {...restInput} />
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
    console.log('onSubmit', this.props)
    return new Promise((resolve, reject) => {
      this.props.firebase.login({ email : values.email, password: values.password })
            .then((cred) => {
              console.log('resolved ');
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
       <ScrollView>

          <Field name="email" title={I18n.t('email')} component={MyTextInput} defaultValue='' floatingLabel />

          <Field name="password" title={I18n.t('password')} component={MyTextInput} defaultValue='' secureTextEntry floatingLabel/>
          <Text>{this.state.errorText}</Text>

          <Text>The form is:</Text>
      {
        formStates.filter((state) => this.props[state]).map((state) => {
          return <Text key={state}> - { state }</Text>
        })
      }

          <Button block primary style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSubmit)} >
            <Text>{I18n.t('signin')}</Text>
          </Button>
          <Button block light style={{ margin: 15 }} onPress={this.handleForgotPassword} >
            <Text>{I18n.t('forgotpassword')}</Text>
          </Button>
          <Button block light style={{ margin: 15 }} onPress={this.handleSignUp} >
            <Text>{I18n.t('signup')}</Text>
          </Button>
          <Button block light style={{ margin: 15 }} onPress={this.handleVerify} >
            <Text>{I18n.t('verifyemail')}</Text>
          </Button>
        </ScrollView>
    );
  }
};

export default reduxForm({
  form: 'Login',
  onSubmit: values => {
    console.log('this one')
    console.log(values)

  },
  validate: values => {
    const errors = {}
    console.log(values)

    if (!values.email) {
      errors.email = I18n.t('needemail')
    }

    if (!values.password) {
      errors.password = I18n.t('needpassword')
    }
    console.log('in here', errors)

    // Do the actual login here.
    return errors
  }
})(withFirestore(withNavigation(LoginFormView)))
