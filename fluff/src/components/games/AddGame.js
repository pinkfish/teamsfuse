import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import { connect } from 'react-redux';
import { compose } from 'redux';
import { FlatList } from 'react-native';
import {
  Container,
  Text,
  Button
} from "native-base";
import styles from './styles';
import { firestoreConnect } from 'react-redux-firebase';
import { withNavigation } from 'react-navigation';
import I18n from '../../../i18n/I18n';

const camera = require("../../../assets/camera.png");

class AddGame extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  onPressItem = () => {
    // updater functions are preferred for transactional updates
    console.log(this.child);
    this.child.doSubmit();
  };

  keyExtractor = (item, index) => item.uid;

  renderItem = (item) => {
    return <Button transparent>
      <Text>{item.name}</Text>
    </Button>
  }

  addTeam = () => {
    this.props.navigation.navigate("EditTeam", { uid: 0 });
  }

  render() {
    const { teams } = this.props;

    if (!teams || teams.length == 0) {
      return <Container>
        <ModalHeader title={I18n.t('addevent')} iconRight="check" onRightPress={this.onPressItem}/>
        <Text>{I18n.t('noteams')}</Text>
        <Button  onPress={this.addTeam} transparent >
          <Text>{I18n.t('addteam')}</Text>
        </Button>
      </Container>;
    }
    return (
      <Container>
        <ModalHeader title={I18n.t('addevent')} iconRight="check" onRightPress={this.onPressItem}/>
        <Text>{I18n.t('teamselect')}</Text>

        <FlatList
          data={teams}
          extraData={this.state}
          keyExtractor={this.keyExtractor}
          renderItem={this.renderItem}
        />
      </Container>
    );
  }
}

const enhance = compose(
  // Pass data from redux as a prop
  connect(({ firebase: { auth }, firebase: { ordered } }) => ({
    auth,
    teams: ordered.teams
  })),
  firestoreConnect(props => [
    {
      collection: 'Teams',
      storeAs: 'teams',
      where: [['user.uid', '==', props.auth.uid]],
    },
  ]),
  withNavigation
);

export default enhance(AddGame);
