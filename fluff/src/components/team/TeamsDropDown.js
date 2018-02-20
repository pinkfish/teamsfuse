import React, { Component } from 'react'
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect } from 'react-redux-firebase';
import { View,  StyleSheet, ActivityIndicator, TouchableOpacity, FlatList, Alert, Platform } from 'react-native';
import { Container, Header, Title, Content, Button, Text, Right, Body, Left, Picker, Form, Item as FormItem } from 'native-base';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import I18n from '../../../i18n/I18n';
//import styles from './styles';


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
)

const Item = Picker.Item;
class TeamsDropDown extends Component {
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
    const { teams, currentTeam, ...rest } = this.props;
    if (!teams || teams.length == 0) {
      return (<Button onPress={() => this.navigation.navigate("EditTeam", {teamId : 0 })} {...rest}>
               <Text>{I18n.t('addteam')}</Text>
             </Button>);
    }
    if (!currentTeam) {
      currentTeam.teamdId = 0;
    }
    return (
        <Picker
          iosHeader={I18n.t('selectone')}
          mode="dropdown"
          selectedValue={currentTeam.teamId}
          onValueChange={this.onValueChange.bind(this)}
          {...rest}
        >
          {team && teams.map((team) => {

              return (
                  <Item label={team.name} key={team.uid} />
              );
          })}
        </Picker>
    );
  }
}


export default enhance(TeamsDropDown);
