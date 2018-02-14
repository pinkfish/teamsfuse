
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

  render() {
    const { handleSubmit, submitting } = this.props

    console.log("Rendering loginform");

    return (
       <ScrollView style={styles.container}>

            <Label floatingLabel >{I18n.t('email')}</Label>
            <Field name="email" component={MyTextInput} floatingLabel />

            <Label floatingLabel>{I18n.t('password')}</Label>
            <Field name="password" component={MyTextInput} secureTextEntry floatingLabel/>
            <Text>{this.state.errorText}</Text>

          <Button block style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSubmit)} >
            <Text>Sign In</Text>
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

    //values = values.toJS()

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
})(withFirestore(LoginFormView))
