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
    currentTeam: state.currentTeam
  })),
  // Show activity indicator while loading todos
  //spinnerWhileLoading(['opponents'])
)

const Item = Picker.Item;
export default class TeamsDropDown extends Component {
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

  renderList() {

  }

  render() {
    if (!teams || teams.length == 0) {
      return <Button onPress={() => this.navigation.navigate("EditTeam", {teamId : 0 })}>
               <Text>{I18n.t('addteam')}</Text>
             </Button>
    }
    return (
        <Picker
          iosHeader={I18n.t('selectone')}
          mode="dropdown"
          selectedValue={this.props.currentTeam.teamId}
          onValueChange={this.onValueChange.bind(this)}
        >
          {team && teams.map((team) => {

              return (
                  <Item label={team.name} key={team.teamId} />
              );
          })}

        </Picker>
    );
  }
}


export default enhance(TeamsDropDown);
