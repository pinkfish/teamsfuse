
import React, { Component, View } from "react";
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
import SignupForm from './SignupForm';
import I18n from '../../../i18n/I18n';


class SignUp extends Component {
  render() {
    const { handleSubmit, submitting } = this.props

    return (
      <Container style={styles.container}>
        <Content>
          <SignupForm />
          <Button
            buttonStyle={{ marginTop: 20 }}
            backgroundColor="transparent"
            textStyle={{ color: "#bcbec1" }}
            title={I18n.t('login')}
            onPress={() => navigation.navigate("SignIn")}
          />
        </Content>
      </Container>
    );
  }
}

export default SignUp;
