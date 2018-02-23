import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirestore, login, logout } from 'react-redux-firebase';
import {
  Button,
  Header,
  Title,
  Item,
  Left,
  Right,
  Content,
  Card,
  CardItem,
  Text,
  Body,
  Container,
  Fab,
  List,
  ListItem,
  Thumbnail
} from "native-base";
import { Image } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';
import { Field, reduxForm, submit } from 'redux-form'
import MyTextInput from "../utils/MyTextInput";
import { withNavigation } from 'react-navigation';
import TeamListPicker from '../team/TeamListPicker';


const camera = require("../../../assets/camera.png");

class EditOpponentForm extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  componentDidMount() {
    this.props.onMyFormRef(this)
  }

  componentWillUnmount() {
    this.props.onMyFormRef(undefined)
  }

  doSubmit = () =>{
    this.props.handleSubmit(this.mySubmitCheck)();
  }

  mySubmitCheck = (values, dispatch) => {
    console.log('mySubmitCheck', values, this.props.auth);
    return new Promise((resolve, reject) => {
      if (this.props.navigation.state.params.opponentId != 0) {
        console.log('update', values, this.props.navigation.state.params);
        this.props.firebase.update(this.opponentId, {
          name: values.name,
          contact: values.contact })
              .then((cred) => {
                resolve();
                console.log('Submit done ', this.props.auth);
                this.props.navigation.goBack();
              })
              .catch((error) => {
                // Update the field with an error string.
                this.setState({errorText: error.message});
                resolve();
              })
      } else {
        console.log('push', values, this.props.auth);
        this.props.firebase.push('Opponents', {
        name: values.name,
        contact: values.contact })
            .then((cred) => {
              resolve();
              console.log('Submit done ', this.props.auth);
              this.props.navigation.goBack();
            })
            .catch((error) => {
              // Update the field with an error string.
              this.setState({errorText: error.message});
              resolve();
            })
    }
    })
  }

  render() {
    const { teamuid, opponentuid, teams } = this.props;

    return (
      <Content style={{ flex: 1, backgroundColor: "#fff", top: -1 }}>
        <List>
          <Field name="teamuid" title={I18n.t('selectteam')} component={TeamListPicker} teams={teams} />
          <Field name="name" title={I18n.t('name')} component={MyTextInput} defaultValue={opponent?opponent.name:''} floatingLabel />
          <Field name="contact" title={I18n.t('contact')} component={MyTextInput} defaultValue={opponent?opponent.contact:''} secureTextEntry floatingLabel last/>
          <Text>{this.state.errorText}</Text>
        </List>
      </Content>
    );
  }
}

function mapStateToProps(state) {
  return {
    teams: state.teams,
    opponentuid: this.props.navigation.state.params.opponentuid,
    initialValues: () => {
      teamuid = this.props.navigation.state.params.teamuid;
      oppponentuid = this.props.navigation.state.params.opponentuid;
      return {
        teamuid: this.props.navigation.state.params.teamuid,
      }
    }
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
