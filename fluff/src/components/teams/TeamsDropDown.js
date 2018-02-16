import React, { Component } from 'react'
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect } from 'react-redux-firebase';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity, FlatList, Alert, Platform } from 'react-native';
import { Container, Header, Title, Content, Button, Icon, Text, Right, Body, Left, Picker, Form, Item as FormItem } from 'native-base';
import { spinnerWhileLoading, } from '../utils/Spinner';
import { ModalHeader } from "../app/AppHeader";
import OpponentCard from './OpponentCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import I18n from '../../../i18n/I18n';
import styles from './styles';


const enhance = compose(
  // Create listener for todos path when component mounts
  firebaseConnect([
    { path: 'Teams' } // create listener for firebase data -> redux
  ]),
  // Pass data from redux as a prop
  connect((state) => ({
    // todos: state.firebase.data.todos, // todos data object from redux -> props.todos
    opponents: state.firebase.ordered.Teams, // todos ordered array from redux -> props.todos
  })),
  // Show activity indicator while loading todos
  //spinnerWhileLoading(['opponents'])
)

const Item = Picker.Item;
export default class PickerExample extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected1: "key1"
    };
  }

  onValueChange(value: string) {
    this.setState({
      selected1: value
    });
  }

  render() {
    return (
      <Container>
        <Header>
          <Left>
            <Button transparent onPress={() => this.props.navigation.goBack()}>
              <Icon name="arrow-back" />
            </Button>
          </Left>
          <Body>
            <Title>{I18n.t('selectteam')}</Title>
          </Body>
          <Right />
        </Header>
        <Content>
          <Form>
            <Picker
              iosHeader="Select one"
              mode="dropdown"
              selectedValue={this.state.selected1}
              onValueChange={this.onValueChange.bind(this)}
            >
              <Item label="Wallet" value="key0" />
              <Item label="ATM Card" value="key1" />
              <Item label="Debit Card" value="key2" />
              <Item label="Credit Card" value="key3" />
              <Item label="Net Banking" value="key4" />
            </Picker>
          </Form>
        </Content>
      </Container>
    );
  }
}
