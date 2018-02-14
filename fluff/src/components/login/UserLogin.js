
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
import LoginForm from './LoginForm';


class UserLogin extends Component {
  render() {
    const { handleSubmit, submitting } = this.props

    console.log("Rendering loginview");


    return (
      <Container style={styles.container}>
        <Header>
          <Left>
            <Button transparent onPress={() => this.props.navigation.goBack()}>
              <Icon name="arrow-back" />
            </Button>
          </Left>
          <Body>
            <Title>Login to Team Fuse</Title>
          </Body>
          <Right />
        </Header>

        <Content>
          <LoginForm />
        </Content>
      </Container>
    );
  }
}

export default UserLogin;
