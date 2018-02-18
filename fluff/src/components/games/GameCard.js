import React, { Component } from "react";
import { Card, CardItem, Body, Left, Right, Icon, Fab } from "native-base";
import Moment from 'react-moment';
import styles from '.styles';

function getRecord(game) {
  // Look up the opponent record.
  return "Win: 1 Tie: 0: Loss: 2";
}

function getAvailability(game, player) {
  // Find my availablility.
  const avail = game.availablility[player.id];
  if (avail == 'yes') {
    return <Button iconLeft style={styles.availYes}>
             <Icon name="check" size={25}/>
             <Text>Yes</Text>
           </Button>;
  } else if (avail == 'no') {
    return <Button iconLeft style={styles.availNo}>
             <Icon name="minus" size={25}/>
             <Text>No</Text>
           </Button>;
  } else {
    return <Button iconLeft style={styles.availMaybe}>
             <Icon name="question" size={25}/>
             <Text>Maybe</Text>
           </Button>;
  }
}

class GameList extends React.PureComponent {
  render() {
    { game, player } = this.props;

    var formattedDate = new Date(game.time);


    return (<Card>
      <CardItem>

        <Body>
          <Text>{game.opponent}</Text>
          <Moment format="ddd DD MMM HH:MM" unix>{game.time}</Moment>
          <Text style={styles.oppponentRecord}>{getRecord(game.opponent)}</Text>
        </Body>
        <Right>
           {getAvailability(game, player)}
        </Right>
      </CardItem>
    </Card>)
  }
}
