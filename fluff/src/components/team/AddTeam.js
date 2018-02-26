import React, { Component, PropTypes } from 'react';
import { View, Modal } from 'react-native';
import AddTeam1 from './add/AddTeam1';
import AddTeam2 from './add/AddTeam2';
import AddTeam3 from './add/AddTeam3';
import { Container, Spinner, Text, Button } from 'native-base';
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import RNFirebase from 'react-native-firebase';
import styles from './styles';
import GUID from '../utils/GUID';


class AddTeam extends Component {
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
    uid = GUID();
    seasons = {}
    seasons[uid] = {
      name: values.season,
      current: true,
      record: {
        win: 0,
        loss: 0,
        tie: 0
      }
    }
    RNFirebase.firestore().collection("Teams").add({
      name: values.name,
      league: values.league,
      gender: values.gender,
      sport: values.sport,
      player: player,
      record: {
        win: 0,
        tie: 0,
        loss: 0
      }
      seasons: seasons
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
        <ModalHeader title={I18n.t('addteam')} />

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

        {page === 1 && <AddTeam1 onSubmit={this.nextPage}/>}
        {page === 2 && <AddTeam2 previousPage={this.previousPage} onSubmit={this.nextPage}/>}
        {page === 3 && <AddTeam3 previousPage={this.previousPage} onSubmit={this.onSubmit}/>}
      </Container>
    );
  }
}

export default AddTeam
