import React, { Component } from 'react'
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect } from 'react-redux-firebase';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity, FlatList, Alert } from 'react-native';
import { ActionSheet, Container, Fab, Content, Thumbnail } from 'native-base';
import { spinnerWhileLoading, } from '../utils/Spinner';
import { ModalHeader } from "../app/AppHeader";
import OpponentCard from './OpponentCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import I18n from '../../../i18n/I18n';
import styles from './styles';


const enhance = compose(
  // Create listener for todos path when component mounts
  firebaseConnect([
    { path: 'Opponents' } // create listener for firebase data -> redux
  ]),
  // Pass data from redux as a prop
  connect((state) => ({
    // todos: state.firebase.data.todos, // todos data object from redux -> props.todos
    opponents: state.firebase.ordered.Opponents, // todos ordered array from redux -> props.todos
  })),
  // Show activity indicator while loading todos
  //spinnerWhileLoading(['opponents'])
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

  listDetails(opponents) {
    if (!opponents || opponents.length == 0) {
      return <Text>No opponents</Text>
    }
    return <FlatList
      data={opponents.reverse()}
      style={styles.list}
      renderItem={({ item: { key, value } }) => (
          <TouchableOpacity onPress={this.onPress}>
            <OpponentCard opponentId={key} opponent={value} />
          </TouchableOpacity>
      )}
    />;
  }

  render() {
    const { opponents } = this.props;

    return (
      <Container>
        <ModalHeader title={I18n.t('opponents')} />
        <Content padder>

          {this.listDetails(opponents)}
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
