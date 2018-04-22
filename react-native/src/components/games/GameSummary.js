import React, { Component } from "react";
import { Content, Card, CardItem, Text, Body } from "native-base";

export default class GameSummary extends React.PureComponent {
  _onPress = () => {
    this.props.onPressItem(this.props.id);
  };

  render() {

    return (
        <Card>
          <CardItem header>
            <Text>{this.props.title}</Text>
          </CardItem>
          <CardItem>
            <Body>
              <Text>{this.props.description}</Text>
            </Body>
          </CardItem>
        </Card>
    );
  }
}
