import React, { Component, PropTypes } from 'react'
import { View, Modal } from 'react-native'
import AddGame1 from './add/AddGame1'
import AddGame2 from './add/AddGame2'
import { Container, Spinner, Text, Button } from 'native-base';
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import RNFirebase from 'react-native-firebase';
import styles from './styles';


class AddGame extends Component {
  constructor(props) {
    super(props)
    this.nextPage = this.nextPage.bind(this)
    this.previousPage = this.previousPage.bind(this)
    this.state = {
      page: 1,
      errorVisible: false,
      savingVisible: false,
      error: ''
    }
  }
  nextPage() {
    this.setState({ page: this.state.page + 1 })
  }

  previousPage() {
    this.setState({ page: this.state.page - 1 })
  }

  onSubmit = (values) => {
    player = {}
    player[values.playeruid] = {
      added: true,
    }
    this.setState({ savingVisible: true });
    RNFirebase.firestore().collection("Teams").add({
      name: values.name,
      league: values.league,
      gender: values.gender,
      sport: values.sport,
      player: player
    }).then(() => {
      this.setState({ savingVisible: false });
      this.props.navigation.goBack();
    }).catch(() => {
      this.setState({error: 'Error saving team', errorVisible : true });
    })
    // Move to saving state.
  }

  render() {
    const { page } = this.state
    return (
      <Container>
        <ModalHeader title={I18n.t('addevent')} />

        <Modal
           visible={this.state.savingVisible}
           animationType={'slide'}
           onRequestClose={() => this.closeModal()}
         >
           <View style={styles.modalContainer}>
             <View style={styles.innerContainer}>
               <Text>Saving</Text>
               <Spinner color="green" />
             </View>
           </View>
        </Modal>

        <Modal
           visible={this.state.errorVisible}
           animationType={'slide'}
           onRequestClose={() => this.closeModal()}
         >
           <View style={styles.modalContainer}>
             <View style={styles.innerContainer}>
               <Text>Error</Text>
               <Text error>{this.state.error}</Text>
               <Button onPress={() => this.closeModal()} title="Ok" />
             </View>
           </View>
        </Modal>

        {page === 1 && <AddGame1 onSubmit={this.nextPage}/>}
        {page === 2 && <AddGame2 previousPage={this.previousPage} onSubmit={this.nextPage}/>}
    </Container>
    );
  }
}

export default AddGame
