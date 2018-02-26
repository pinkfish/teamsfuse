import React, { Component, PropTypes } from 'react'
import { View, Modal } from 'react-native'
import AddPractice1 from './add/AddPractice1'
import AddPractice2 from './add/AddPractice2'
import { Container, Spinner, Text, Button } from 'native-base';
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import RNFirebase from 'react-native-firebase';
import styles from './styles';
import SavingModal from '../utils/SavingModal';
import momenttz from 'moment-timezone';


class AddPractice extends Component {
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
    timeInZone = momenttz.tz(timeObj, values.place.timeZoneId);

    RNFirebase.firestore().collection("Teams").doc(teamuid).collection("Games").add({
      time: timeInZone,
      timezone: values.place.timeZoneId,
      timezoneName: values.place.timeZoneName,
      duration: values.duration,
      place: {
        name: values.place.name,
        address: values.place.address,
        placeid: values.place.placeid,
        notes: values.placenotes,
      },
      notes: values.notes,
      attendence: {
      }
    }).then(() => {
      this.setState({ savingVisible: false });
      this.props.navigation.goBack();
    }).catch(() => {
      this.setState({error: 'Error saving team', errorVisible : true });
    })
    // Move to saving state.
  }

  doFormSubmit = () => {
    this.child.doSubmit();
  }

  render() {
    const { page, savingVisible, errorVisible } = this.state;
    console.log('my state' , this.state);
    return (
      <Container>
        <ModalHeader title={I18n.t('addpractice')} iconRight="check" onRightPress={this.doFormSubmit} />

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

        {page === 2 && <AddPractice1 onSubmit={this.nextPage} onMyFormRef={(ref) => (this.child = ref)}/>}
        {page === 1 && <AddPractice2 previousPage={this.previousPage} onSubmit={this.handleSubmit} onMyFormRef={(ref) => (this.child = ref)}/>}
    </Container>
    );
  }
}

export default AddPractice
