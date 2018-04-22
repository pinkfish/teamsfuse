import React, { Component } from "react";
import { FlatList, View } from "react-native";
import { Button, Icon, Fab, Text, List, Body, Thumbnail, ListItem, Left } from "native-base";
import GameSummary from "./GameSummary";
import { withNavigation } from "react-navigation";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { firestoreConnect } from 'react-redux-firebase';
import I18n from '../../../i18n/I18n';
import { getDisplayTime } from '../../data/Game';

class GameList extends React.PureComponent {
  constructor(props, context) {
    super(props, context);
    this.state = {
         active: true
    }
  }

  _keyExtractor = (item, index) => item.id;

  _onPressItem = () => {
    // updater functions are preferred for transactional updates
    this.navigation.navigate("AddGame");
  };

  _renderItem = (team) => {
    return <Text>{team.title}</Text>;
  }

  render() {
    const { games, teams } = this.props;

    if (!games || !games.list || games.list.length == 0) {
      return <Text>{I18n.t('nogames')}</Text>;
    }
    ret = [];
    for (key in games.list) {
      game = games.list[key];
      ret.push(<ListItem itemDivider key={game.uid + 'div'}>
        <Text>{getDisplayTime(game).format('dd MMM')}</Text>
      </ListItem>);
      team = teams.list[game.teamuid];
      opponentName = I18n.t('unknown');
      opponents = team.opponents;
      console.log('team', opponents, team);
      //pponentName = team.opponents[game.opponentuid];
      ret.push( <ListItem avatar key={game.uid}>
                  <Left>
                    <Thumbnail source={{uri: '../../../assets/sport/' + game.sport + '.png'}} />
                  </Left>
                  <Body>
                    <Text>{getDisplayTime(game).format('hh:mm A z')} vs {opponentName}</Text>
                    <Text>{game.place.name}</Text>
                  </Body>
                </ListItem>);
    }
    return (
      <List>
        {ret}
      </List>
    );
  }
};

function mapStateToProps(state) {
  return {
    games: state.games,
    teams: state.teams
  }
}


const enhance = compose(
  // Pass data from redux as a prop
  connect(mapStateToProps),
  withNavigation
);

export default enhance(GameList);
