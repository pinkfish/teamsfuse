import React, { Component } from "react";
import { Content, Container, Card, CardItem, Text, Body, Button, Fab } from "native-base";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { firestoreConnect, withFirestore } from 'react-redux-firebase';
import Icon from '../utils/Icon';
import GameList from "../games/GameList";
import { withNavigation } from 'react-navigation';
import I18n from '../../../i18n/I18n';

class Home extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = { active: false };
  }

  addGame = () => {
    this.props.navigation.navigate("AddGame");
  }

  addTeam = () => {
    this.props.navigation.navigate("AddTeam", { uid: 0 });
  }

  render() {
    const { games, teams } = this.props;

    if (!teams || teams.length == 0) {
      return <Container>

      <Content padder>
        <Text>{I18n.t('noteams')}</Text>
        <Button  onPress={this.addTeam} transparent >
          <Text>{I18n.t('addteam')}</Text>
        </Button>
      </Content>
      <Fab
          active={true}
          direction="up"
          containerStyle={{ }}
          style={{ backgroundColor: '#5067FF' }}
          position="bottomRight"
          onPress={this.addGame}>
          <Icon name="mat-add" />
      </Fab>
    </Container>
    }
    return
      <Content>
        <GameList />
        <Fab
            direction="up"
            containerStyle={{ }}
            style={{ backgroundColor: '#5067FF' }}
            position="bottomRight"
            onPress={this.addGame}>
            <Icon name="add" />
        </Fab>
      </Content>
  }
}

function mapStateToProps(state) {
  return { currentPlayer: state.currentPlayer }
}

const enhance = compose(
  // Pass data from redux as a prop
  connect(({ firebase: { auth }, firebase: { ordered } }) => ({
    auth,
    games: ordered.games,
    teams: ordered.teams
  })),
  connect(mapStateToProps),
  firestoreConnect(props => [
    {
      collection: 'Games',
      storeAs: 'games',
      where: [['user.uid', '==', props.auth.uid]],
    },
    {
      collection: 'Teams',
      storeAs: 'teams',
      //where: [['user.uid', '==', props.auth.uid]],
      where: [ `Teams.${props.currentPlayer.uid}`, '==', true],
    },
    {
      collection: 'Player',
      storeAs: 'players',
      //where: [['user.uid', '==', props.currentPlayer.uid ]],
      where: [ `Player.${props.auth.uid}`, '==', true ],
    }
  ]),
  withNavigation
);

export default enhance(Home);
