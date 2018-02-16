import React, { Component } from 'react'
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect } from 'react-redux-firebase';
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native';
import { Container, Fab, Content } from 'native-base';
import { spinnerWhileLoading, } from '../utils/Spinner';
import { ModalHeader } from "../app/AppHeader";
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';


const enhance = compose(
  // Create listener for todos path when component mounts
  firebaseConnect([
    { path: 'opponents' } // create listener for firebase data -> redux
  ]),
  // Pass data from redux as a prop
  connect((state) => ({
    // todos: state.firebase.data.todos, // todos data object from redux -> props.todos
    opponents: state.firebase.ordered.opponents, // todos ordered array from redux -> props.todos
  })),
  // Show activity indicator while loading todos
  //spinnerWhileLoading(['opponents'])
)

class OpponentList extends Component {
  onPressItem = () => {
    this.props.navigation.navigate("EditOpponent", { opponentId: 0 });
  }

  listDetails(opponents) {
    if (!opponents || opponents.length() == 0) {
      return <Text>No opponents</Text>
    }
    return <FlatList
      data={opponents.reverse()}
      style={styles.list}
      renderItem={({ item: { key, value } }) => (
          <OpponentCard opponentId={key} opponent={value} />
      )}
    />;
  }

  render() {
    const { opponents } = this.props;

    return (
      <Container>
        <ModalHeader />
        <Content padder>

          {this.listDetails(opponents)}
          <Fab
              direction="up"
              containerStyle={{ }}
              style={{ backgroundColor: '#5067FF' }}
              position="bottomRight"
              onPress={() => this.onPressItem }>
              <Icon name="add" />
          </Fab>
        </Content>
      </Container>
    );
  }
}

export default enhance(OpponentList);
