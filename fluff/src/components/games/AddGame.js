import React, { Component, PropTypes } from 'react'
import { View, Modal } from 'react-native'
import AddGame1 from './add/AddGame1'
import AddGame2 from './add/AddGame2'
import { Container, Spinner, Text, Button } from 'native-base';
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import RNFirebase from 'react-native-firebase';
import styles from './styles';
import SavingModal from '../utils/SavingModal';
import momenttz from 'moment-timezone';


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
    // Do stuff with the time and date, convert to a single number
    var timeObj =
    {
      hour: values.time.getHour(),
      minute: valuestiome.getMinute(),
      year: values.date.getYear(),
      month: values.date.getMonth(),
      day: values.date.getDay(),
    };
    // Make a date in the timezone we are going to.
    timeInZone = momenttz.tz(timeObj, values.timezone);

    RNFirebase.firestore().collection("Teams").doc(teamuid).collection("Games").add({
      time: timeInZone,
      timezone: values.timezone,
      place: {
        name: values.place.name,
        address: values.place.address,
        placeid: values.place.placeid,
        notes: values.placenotes,
      },
      opponent: values.opponentuid,
      result: 'unknown',
    }).then(() => {
      this.setState({ savingVisible: false });
      this.props.navigation.goBack();
    }).catch(() => {
      this.setState({error: 'Error saving team', errorVisible : true });
    })
    // Move to saving state.
  }

  render() {
    const { page, savingVisible, errorVisible } = this.state;
    console.log('my state' , this.state);
    return (
      <Container>
        <ModalHeader title={I18n.t('addevent')} />

        <SavingModal onClose={() => this.setState({ savingVisible: false })} visible={savingVisible} />

        <Modal
           visible={errorVisible}
           animationType={'slide'}
           onRequestClose={() => this.setState({ errorVisible: false })}
         >
           <View style={styles.modalContainer}>
             <View style={styles.innerContainer}>
               <Text>Error</Text>
               <Text error>{this.state.error}</Text>
               <Button onPress={() => this.setState({ errorVisible: false })} title="Ok" />
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
