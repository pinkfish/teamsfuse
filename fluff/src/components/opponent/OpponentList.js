import React, { Component } from 'react'
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firestoreConnect } from 'react-redux-firebase';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity, FlatList, Alert } from 'react-native';
import { ActionSheet, Container, Fab, Content, Thumbnail } from 'native-base';
import { spinnerWhileLoading, } from '../utils/Spinner';
import { ModalHeader } from "../app/AppHeader";
import OpponentCard from './OpponentCard';
import Icon from '../utils/Icon';
import I18n from '../../../i18n/I18n';
import styles from './styles';


const enhance = compose(
  // Pass data from redux as a prop
  connect((state) => ({
    teams: state.teams,
    games: state.games
  })),
)

const BUTTONS = [
  I18n.t('showrecord'),
  I18n.t('edit'),
  I18n.t("delete"),
  I18n.t("cancel")
];

class OpponentList extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  onPressItem = () => {
    console.log('onPressItem')
    this.props.navigation.navigate("EditOpponent", { opponentId: 0, opponent: { name: '', contact: '' } });
  }

  onPress = (opponentId, opponent) => {
    ActionSheet.show(
              {
                options: BUTTONS,
                cancelButtonIndex: 3,
                destructiveButtonIndex: 2,
                title: I19n.t("opponentaction")
              },
              buttonIndex => {
                if (buttonIndex == 1) {
                  this.props.navigation.navigate('EditOpponent', { opponentId: opponentId, opponent: opponent })
                } else if (buttonIndex == 2) {
                  Alert.alert(
                    I18n.t('deleteopponent'),
                    I18n.t('deleteopponentsure'),
                    [
                      {text: I18n.t("Cancel"), onPress: () => { return; }},
                      {text: I18n.t("OK"), onPress: () => this.firebase.delete({ collection: 'Opponents', doc: opponentId })},
                    ],
                  )
                }
              }
            )
  }

  listDetails(teams) {
    if (!teams || teams.length == 0) {
      return <Text>No opponents</Text>
    }
    ret = [];
    for(var key in teams) {
      if (teams.list.hasOwnProperty(key)) {
        ret.push(renderTeam(teams.list[key]));
      }
    }
    return ret;
  }

  renderGame(game) {
    return <Text>{game.result}</Text>;
  }

  renderOpponent(opponent) {
    int win = 0;
    int tie = 0;
    int loss = 0;
    int unknown = 0;
    myGames = this.games.values().filter(
      game => game.opponentuid == opponent.uid
    );
    return <Card>
             <Text>{opponent.name}</Text>
             <Text>Win 1, Tie 2, Loss 3</Text>
             <FlatList
                 data={myGames}
                 renderItem={this.renderGame}
                 />
           </Card>;
  }

  renderTeam(team) {
    ret = [<ListItem header><Text>{team.name}</Text></ListItem>];
    for(var key in team.opponents) {
      if (team.opponents.hasOwnProperty(key)) {
        ret.push(renderOpponent(team.opponents[key]));
      }
    }
    return ret;
  }

  render() {
    const { teams, teamuid } = this.props;

    return (
      <Container>
        <ModalHeader title={I18n.t('opponents')} />
        <Content padder>
          <List>
            {teams.list.hasOwnProperty(teamuid) ? this.renderTeam(teams.list[teamuid]) : this.listDetails(teams)}
          </List>
        </Content>
        <Fab
            active={true}
            direction="up"
            containerStyle={{ }}
            style={{ backgroundColor: '#5067FF' }}
            position="bottomRight"
            onPress={() => this.onPressItem() }>
            <Icon name="plus" />
        </Fab>
      </Container>
    );
  }
}

export default enhance(OpponentList);
