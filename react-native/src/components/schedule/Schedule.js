import React, { Component } from "react";
import { Content, Card, CardItem, Text, Body } from "native-base";
import GameList from  "../games/GameList";

export default class Schedule extends Component {
  render() {
    return (
      <Content padder style={{ marginTop: 0 }}>
        <GameList />
      </Content>
    );
  }
}
