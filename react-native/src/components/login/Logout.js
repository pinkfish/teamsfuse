
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
import { withFirestore } from 'react-redux-firebase';

class UserLogin extends Component {
  constructor(props, context) {
    super(props, context);
    this.logout = this.logout.bind(this);
    this.state = {
         errorText: ''
    }
  }

  logout() {
    this.firebase.logout();
  }

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
            <Button>Teamfuse</Title>
          </Body>
          <Right />
        </Header>

        <Content>
          <Button onPress={() => this.logout()}>
            <Text>{I18n.t('logout')}</Text>
          </Button>
          <Text>{this.state.errorText}</Text>
        </Content>
      </Container>
    );
  }
}

export default withFirestore(UserLogin);
