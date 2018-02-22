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
    this.props.navigation.navigate("AddGame", { type: 'game' });
  }

  addPractice = () => {
    this.props.navigation.navigate("AddGame", { type: 'addPractice' });
  }

  addEvent = () => {
    this.props.navigation.navigate("AddGame", { type: 'event' });
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
    ret = (
      <Container>
        <Content>
          <Text>SOmething here</Text>
          <GameList />
        </Content>
        <Fab
            active={this.state.active}
            direction="up"
            containerStyle={{ }}
            style={{ backgroundColor: '#5067FF' }}
            position="bottomRight"
            onPress={() => this.setState({active: !this.state.active })}>
            <Icon name="mat-add" />
            <Button style={{ backgroundColor: '#34A34F' }} onPress={this.addGame}>
              <Text>{I18n.t('addgame')}</Text>
              <Icon name="gamepad" />
            </Button>
            <Button style={{ backgroundColor: '#3B5998' }} onPress={this.addPractice}>
              <Text>{I18n.t('addpractice')}</Text>
              <Icon name="mat-people" />
            </Button>
            <Button disabled style={{ backgroundColor: '#DD5144' }} onPress={this.addEvent}>
              <Text>{I18n.t('addevent')}</Text>
              <Icon name='calendar' />
            </Button>
        </Fab>
      </Container>);

      return ret;
  }
}

function mapStateToProps(state) {
  return {
    currentPlayer: state.currentPlayer,
    teams: state.teams,
    games: state.games
  }
}

const enhance = compose(
  // Pass data from redux as a prop
  connect(({ firebase: { auth }, firebase: { ordered } }) => ({
    auth,
  })),
  connect(mapStateToProps),
  withNavigation
);

export default enhance(Home);
