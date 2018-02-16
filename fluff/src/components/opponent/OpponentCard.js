import React, { Component } from "react";
import { ActionSheet, Card, CardItem, Body, Left, Right, Fab, Text, Thumbnail } from "native-base";
import Moment from 'react-moment';
import styles from './styles';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const logo = require("../../../assets/logo.png");


function getRecord(game) {
  // Look up the opponent record.
  return "Win: 1 Tie: 0: Loss: 2";
}


export default class OpponentCard extends React.PureComponent {
  render() {
    const { opponent, opponentId } = this.props;

    return (<Card key={opponentId}>
      <CardItem header>
        <Thumbnail source={logo} />
        <Body>
          <Text style={styles.opponentBox}>
            {opponent.name}
          </Text>
          <Text note>{getRecord(opponent.opponent)}</Text>
        </Body>
      </CardItem>
      <CardItem>
        <Text>Contact </Text>
        <Text>{opponent.contact}</Text>
      </CardItem>
    </Card>)
  }
}
