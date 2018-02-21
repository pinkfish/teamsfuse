import React, { Component } from "react";
import { FlatList, View } from "react-native";
import { Button, Icon, Fab, Text } from "native-base";
import GameSummary from "./GameSummary";
import { withNavigation } from "react-navigation";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { firestoreConnect } from 'react-redux-firebase';

class GameList extends React.PureComponent {
  constructor(props, context) {
    super(props, context);
    this.state = {
         active: true
    }
  }

  _keyExtractor = (item, index) => item.id;

  _onPressItem = () => {
    // updater functions are preferred for transactional updates
    this.navigation.navigate("AddGame");
  };

  _renderItem = (team) => {
    return <Text>{team.title}</Text>;
  }

  render() {
    return (
      <View>
        <FlatList
          data={ [ { id: '12', title: 'bing', description: 'desc'},
        { id: '13', title: 'rabbit', description: 'bingle'} ] }
          extraData={this.state}
          keyExtractor={this._keyExtractor}
          renderItem={this._renderItem}
        />
      </View>
    );
  }
};

function mapStateToProps(state) {
  return {
    games: state.games
  }
}


const enhance = compose(
  // Pass data from redux as a prop
  connect(mapStateToProps),
  withNavigation
);

export default enhance(GameList);
