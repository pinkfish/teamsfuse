import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirestore, login, logout } from 'react-redux-firebase';
import {
  Content,
  Text,
  Container,
  List
} from "native-base";
import styles from './styles';
import { Field, reduxForm } from 'redux-form'
import { withNavigation } from 'react-navigation';
import MyTextInput from "../utils/MyTextInput";
import TeamListPicker from '../team/TeamListPicker';
import RNFirebase from 'react-native-firebase';
import SavingModal from '../utils/SavingModal';
import FormRefComponent from '../utils/FormRefComponent';


const camera = require("../../../assets/camera.png");

class EditOpponentForm extends FormRefComponent {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: '',
         savingVisible: false
    }
  }

  mySubmitCheck = (values, dispatch) => {
    console.log('mySubmitCheck', values, this.props.auth);
    this.setState({ savingVisible: true });
    if (this.props.teamuid != null) {
      teamuid = this.props.teamuid;
    } else {
      teamuid = values.teamuid;
    }
    return new Promise((resolve, reject) => {
      if (this.props.opponentuid == 0) {
        console.log('update', values, this.props);
        RNFirebase.firestore().collection("Teams").doc(teamuid)
            .collection("Opponents").add({
          name: values.name,
          conect: values.contact
        }).then(() => {
          this.setState({ savingVisible: false });
          this.props.navigation.goBack();
        }).catch(() => {
          this.setState({error: 'Error saving team', errorVisible : true });
        });
      } else {
        RNFirebase.firestore().collection("Teams").doc(teamuid)
            .collection("Opponents").doc(this.props.opponentuid).set({
          name: values.name,
          conect: values.contact
        }).then(() => {
          this.setState({ savingVisible: false });
          this.props.navigation.goBack();
        }).catch(() => {
          this.setState({error: 'Error saving team', errorVisible : true });
        });
      }
    });
  }

  render() {
    const { teamuid, teamname, opponentuid, teams, opponent } = this.props;

    console.log('initval ', this.props);

    return (
      <Content style={{ flex: 1, backgroundColor: "#fff", top: -1 }}>
        <SavingModal onClose={() => this.closeModal()} visible={this.state.savingVisible} />

        <List>
          {teamname != null ?
              <Text>{teamname}</Text>:
              <Field name="teamuid" title={I18n.t('teamselect')} component={TeamListPicker} teams={teams} />}
          <Field name="name" placeholder={I18n.t('name')} component={MyTextInput} regular />
          <Field name="contact" placeholder={I18n.t('contact')} component={MyTextInput} secureTextEntry regular last/>
          <Text>{this.state.errorText}</Text>
        </List>
      </Content>
    );
  }
}

function mapStateToProps(state, props) {
  teamuid = props.navigation.state.params.teamuid;
  opponentuid = props.navigation.state.params.opponentuid;
  teamname = null;
  if (state.teams.list.hasOwnProperty(teamuid)) {
    teamname = state.teams.list[teamuid].name;
    if (state.teams.list[teamuid].opponents.hasOwnProperty(opponentuid)) {
      opponent = state.teams.list[teamuid].opponents[opponentuid];

      initValues = {
        teamuid: props.navigation.state.params.teamuid,
        name: opponent.name,
        contact: opponent.contact
      }
    } else {
      initValues =  {
        teamuid: props.navigation.state.params.teamuid,
      }
    }
  } else {
    initValues = {}
  }
  return {
    teams: state.teams,
    teamname: teamname,
    opponentuid: props.navigation.state.params.opponentuid,
    initialValues: initValues
  }
}

const enhance = compose(
  withNavigation,
  reduxForm({
    form: 'EditOpponent',
    validate: values => {
      const errors = {}
      console.log(values)

      //values = values.toJS()

      if (!values.name) {
        errors.name = I18n.t('needname')
      }

      console.log('in here', errors)

      // Do the actual login here.
      return errors
    },
    onSubmit: values => {
    },
  }),
  connect(mapStateToProps)
  );


export default enhance(EditOpponentForm);
