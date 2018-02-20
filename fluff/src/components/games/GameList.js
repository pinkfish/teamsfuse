import React, { Component } from "react";
import { FlatList, View } from "react-native";
import { Button, Icon, Fab } from "native-base";
import GameSummary from "./GameSummary";
import { withNavigation } from "react-navigation";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { firestoreConnect } from 'react-redux-firebase';

class GameList extends React.PureComponent {
  _keyExtractor = (item, index) => item.id;

  _onPressItem = () => {
    // updater functions are preferred for transactional updates
    this.navigation.navigate("AddGame");
  };

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
        <Fab
            active={this.state.active}
            direction="up"
            containerStyle={{ }}
            style={{ backgroundColor: '#5067FF' }}
            position="bottomRight"
            onPress={() => this._onPressItem }>
            <Icon name="add" />
        </Fab>
    </View>
    );
  }
};

const enhance = compose(
  // Pass data from redux as a prop
  connect(({ firebase: { auth }, firebase: { ordered } }) => ({
    auth,
    games: ordered.games
  })),
  firestoreConnect(props => [
    {
      collection: 'Games',
      storeAs: 'games',
      where: [['user.uid', '==', props.auth.uid]],
    },
  ]),
  withNavigation
);

export default enhance(GameList);
