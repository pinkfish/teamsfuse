import React, { Component } from "react";
import { FlatList } from "react-native";
import GameSummary from "./GameSummary";

export default class GameList extends React.PureComponent {
  state = {selected: (new Map(): Map<string, boolean>)};

  _keyExtractor = (item, index) => item.id;

  _onPressItem = (id: string) => {
    // updater functions are preferred for transactional updates
    this.setState((state) => {
      // copy the map rather than modifying state.
      const selected = new Map(state.selected);
      selected.set(id, !selected.get(id)); // toggle
      return {selected};
    });
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
      <FlatList
        data={ [ { id: '12', title: 'bing', description: 'desc'},
      { id: '13', title: 'rabbit', description: 'bingle'} ] }
        extraData={this.state}
        keyExtractor={this._keyExtractor}
        renderItem={this._renderItem}
      />
    );
  }
}
