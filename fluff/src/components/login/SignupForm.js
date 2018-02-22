import React, { Component } from "react";
import { ScrollView } from 'react-native';
import { Field, reduxForm } from 'redux-form'
import I18n from '../../../i18n/I18n';
import { withFirestore } from 'react-redux-firebase';
import {
  Container,
  Button,
  Text,
} from "native-base";
import styles from "./styles";
import MyTextInput from "../utils/MyTextInput";
import RNFirebase from 'react-native-firebase';


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
      this.props.firebase.createUser({ email : values.email, password: values.password },
                                     { displayName: values.displayName, phoneNumber: values.phoneNumber })
            .then((cred) => {
              console.log('resolved ');
              resolve();
              this.navigation.navigate.goBack();
              RNFirebase.firebase.auth().currentUser.sendEmailVerification();
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

    return (
       <ScrollView>

            <Field name="email" title={I18n.t('email')}component={MyTextInput} floatingLabel />

            <Field name="password" title={I18n.t('password')} component={MyTextInput} secureTextEntry floatingLabel/>
            <Field name="passwordCheck" title={I18n.t('password')} component={MyTextInput} secureTextEntry floatingLabel/>
            <Field name="displayName" title={I18n.t('name')} component={MyTextInput} floatingLabel/>
            <Field name="phoneNumber" title={I18n.t('phonenumber')} component={MyTextInput} floatingLabel/>
            <Text>{this.state.errorText}</Text>

          <Button block style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(this.onSubmit)} >
            <Text>{I18n.t('createaccount')}</Text>
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
    if (!values.displayName) {
      errors.displayName = I18n.t('needName')
    }
    if (values.password != values.passwordCheck) {
      errors.passwordCheck = I18n.t('passwordsmustmatch')
    }
    console.log('in here', errors)

    // Do the actual login here.
    return errors
  }
})(withFirestore(LoginFormView))
