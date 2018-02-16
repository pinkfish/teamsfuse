import React, { Component } from "react";
import { Card, CardItem, Body, Left, Right, Fab } from "native-base";
import Moment from 'react-moment';
import styles from '.styles';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

function getRecord(game) {
  // Look up the opponent record.
  return "Win: 1 Tie: 0: Loss: 2";
}


export default class OpponentCard extends React.PureComponent {
  render() {
    const { opponent, opponentId } = this.props;

    var formattedDate = new Date(game.time);

    return (<Card key={opponentId}>
      <CardItem>
        <Body>
          <Text>{opponent.name}</Text>
          <Text style={styles.oppponentRecord}>{getRecord(game.opponent)}</Text>
        </Body>
      </CardItem>
      <CardItem>
        <Text>{opponent.contact}</Text>
      </CardItem>
    </Card>)
  }
}
