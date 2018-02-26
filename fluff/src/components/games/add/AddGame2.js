import React, { Component } from "react";
import I18n from '../../../../i18n/I18n';
import { compose } from 'redux';
import { connect } from 'react-redux';
import {
  Button,
  Header,
  Footer,
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
  Thumbnail,
  Radio,
  Separator
} from "native-base";
import { Image, View } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';
import { Field, reduxForm, submit, getFormValues } from 'redux-form'
import MyTextInput from "../../utils/MyTextInput";
import MyDurationPicker from '../../utils/MyDurationPicker';
import MyCheckbox from "../../utils/MyCheckbox";
import MySwitch from '../utils/MySwitch';
import TimeZonePicker from "../../utils/TimeZonePicker"
import { withNavigation } from 'react-navigation';
import FormRefComponent from '../../utils/FormRefComponent';

class AddGame1 extends FormRefComponent {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: '',
         selected: 'game',
         timezoneEnabled: false
    }
    this.radio = {}
  }

  setRadio = (state) => {
    const { change } = this.props;

    change('type', state);
    this.setState({ selected: state });
  }

  addOpponent = () => {
    const { teamuid } = this.props;
    this.props.navigation.navigate('EditOpponent', { teamuid: teamuid });
  }

  onPlaceChange = (place) => {
    if (place.timeZoneId) {
      // Update the timezone picker.
      this.props.change('timezone', place.timeZoneId);
    }
  }

  render() {
    const { handleSubmit, players, teams, navigation, error, teamuid, timezoneOfPlace, previousPage } = this.props;

   // See if we have the team, or not.
   opponentList = [];
   if (teams.list.hasOwnProperty(teamuid)) {
     // Yay.
     opponentList = [{ title: I18n.t('oppenentadd'), key: 'add', onPress: this.addOpponent }];
     for (key in teams.list[teamuid].opponents) {
       if (teams.list[teamuid].opponents.hasOwnProperty(key)) {
         oppenent =  teams.list[teamuid].opponents[key];
         opponentList.push({ title: opponent.name, key: opponent.uid })
       }
     }
   }
   console.log('fields', this.props);

    return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="homegame" icon="mat-home" title={I18n.t('homegame')} component={MySwitch} regular />
              <Field name="uniform" icon="tshirt-crew" placeholder={I18n.t("uniform")} component={MyTextInput} regular />
              <Separator />
              <Field name="notes" placeholder={I18n.t('notes')} multiline={true} component={MyTextInput} regular />
              <Separator />
              <Field name="gamelength" title={I18n.t('gamelength')} component={MyDurationPicker} regular last />
              <Text>{this.state.errorText}</Text>
            </Body>
          </ListItem>
        </Content>
        <Footer>
          <Left>
            <Button onPress={previousPage} full light>
              <Text style={{color: 'white', alignItems: 'center' }}>{I18n.t('previous')}</Text>
            </Button>
          </Left>
          <Right>
            <Button onPress={handleSubmit} full primary>
              <Text style={{color: 'white', alignItems: 'center' }}>{I18n.t('addgame')}</Text>
            </Button>
          </Right>
        </Footer>
    </Container>
    );
  }
}

function mapStateToProps(state) {
  return {
    teams: state.teams ,
    players: state.players,
    teamuid: getFormValues('AddGame')(state).teamuid,
    timezoneOfPlace: getFormValues('AddGame')(state).timezoneOfPlace,
    time: null,
    date: null,
    arriveearly: 0
  }
}

const enhance = compose(
  reduxForm({
    form: 'AddGame',
    destroyOnUnmount: false, // Preserve the data.
    initialValues: {
      type: 'game',
      name: '',
      teamuid: '',
      place: '',
    },
    validate: values => {
      const errors = {}
      console.log('validate teams p1', values)

      if (!values.teamuid) {
        errors.teamuid = I18n.t('needteam');
      }

      if (!values.opponentuid) {
        errors.opponentuid = I18n.t('needopponent');
      }

      if (values.time == null) {
        errors.time = I18n.t('needtime');
      }

      if (values.date == null) {
        errors.time = I18n.t('needdate');
      }

      // Do the actual login here.
      return errors
    },
    onSubmit: values => {
    },
  }),
  withNavigation,
  connect(mapStateToProps)
  );


export default enhance(AddGame1);
