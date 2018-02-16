import React, { Component } from "react";
import { FlatList, View } from "react-native";
import { Button, Icon, Fab } from "native-base";
import GameSummary from "./GameSummary";
import { withNavigation } from "react-navigation";

class GameList extends React.PureComponent {
  state = {selected: (new Map(): Map<string, boolean>)};

  _keyExtractor = (item, index) => item.id;

  _onPressItem = () => {
    // updater functions are preferred for transactional updates
    this.navigation.navigate("AddGame");
  };

  _renderItem = ({item}) => (
    <GameSummary
      id={item.id}
      onPressItem={this._onPressItem}
      selected={!!this.state.selected.get(item.id)}
      title={item.title}
      description={item.description}
    />
  );

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

export default withNavigation(GameList);
