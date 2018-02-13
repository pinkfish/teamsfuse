
import React, { Component } from "react";
import { View } from 'react-native';
import { Field, reduxForm } from 'redux-form'
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
import firebase from 'react-native-firebase';


const onSubmit = (values, dispatch) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      firebase.auth().signInAndRetrieveDataWithEmailAndPassword(values.email, values.password)
          .then((cred) => {
            resolve();
          });
    }, 1500)
  })
}

const renderInput = ({ input: { onChange, ...restInput }}) => {
  console.log("Rendering input");
  return <Input style={styles.input} onChangeText={(value) => { onChange(value); console.log("onChange<", value); }} {...restInput} />
}


class LoginFormView extends Component {
  render() {
    const { handleSubmit, submitting } = this.props

    console.log("Rendering loginform");

    return (
       <ScrollView style={styles.container}>

            <Label floatingLabel >Email</Label>
            <Field name="email" component={MyTextInput} floatingLabel />

            <Label floatingLabel>Password</Label>
            <Field name="password" component={MyTextInput} secureTextEntry floatingLabel/>

          <Button block style={{ margin: 15, marginTop: 50 }} onPress={handleSubmit(onSubmit)} >
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
      errors.email = 'Email is required.'
    }

    if (!values.password) {
      errors.password = 'Password is required.'
    }
    console.log('in here', errors)

    // Do the actual login here.
    return errors
  }
})(LoginFormView)

/*

import { Field, reduxForm } from 'redux-form'

const submit = values => {
  console.log('submitting form', values)
}

const renderInput = ({ input: { onChange, ...restInput }}) => {
  return <TextInput style={styles.input} onChangeText={onChange} {...restInput} />
}

const Form = props => {
  const { handleSubmit } = props

  return (
    <View style={styles.container}>
      <Text>Email:</Text>
      <Field name="email" component={renderInput} />
      <TouchableOpacity onPress={handleSubmit(submit)}>
        <Text style={styles.button}>Submit</Text>
      </TouchableOpacity>
    </View>
  )
}

export default reduxForm({
  form: 'test'
})(Form)
*/
