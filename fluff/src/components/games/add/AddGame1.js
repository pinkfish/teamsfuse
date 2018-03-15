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
import MyPicker from "../../utils/MyPicker";
import MyRadioGroup from "../../utils/MyRadioGroup";
import MyTimePicker from "../../utils/MytimePicker";
import MyDatePicker from "../../utils/MyDatePicker";
import MyPlacePicker from "../../utils/MyPlacePicker";
import TeamListPicker from "../../team/TeamListPicker";
import SeasonListPicker from "../../team/SeasonListPicker";
import MyDurationPicker from '../../utils/MyDurationPicker';
import MyCheckbox from "../../utils/MyCheckbox";
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
    const { handleSubmit, players, teams, navigation, error, teamuid, timezoneOfPlace, invalid } = this.props;

   // See if we have the team, or not.
   opponentList = [];
   if (teams.list.hasOwnProperty(teamuid)) {
     // Yay.
     opponentList = [{ title: I18n.t('oppenentadd'), key: 'add', onPress: this.addOpponent }];
     team = teams.list[teamuid];
     console.log('team', team);
     for (key in team.opponents) {
       if (team.opponents.hasOwnProperty(key)) {
         opponent =  team.opponents[key];
         opponentList.push({ title: opponent.name, key: opponent.uid })
       }
     }
   }

   return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="teamuid" title={I18n.t('teamselect')} component={TeamListPicker} teams={teams} first />
              <Field icon="mat-people-outline" name="opponentuid"
                title={teamuid != '' ? I18n.t('eventopponent') : I18n.t('teamselectfirst')}
                disabled={teamuid == ''}
                component={MyPicker}
                options={opponentList}
                onUpdate={teamuid == 'add' ? this.addOpponent() : () => {}}
              />
              <Field name="seasonuid" title={I18n.t('season')} component={SeasonListPicker} teams={teams} players={players} teamuid={teamuid} first />
              <Separator style={styles.separator} />
              <Field name="time" title={I18n.t('eventtime')} component={MyTimePicker} />
              <Field name="date" title={I18n.t('eventdate')} component={MyDatePicker} />
              <Field name="arriveearly" title={I18n.t('earlyarrival')} component={MyDurationPicker} regular />
              <Separator style={styles.separator} />
              <Field name="place" title={I18n.t('eventplace')} icon="mat-note" component={MyPlacePicker} onFormChange={this.onPlaceChange} />
              <Field icon="mat-place" name="placenotes" placeholder={I18n.t('placenotes')} multiline={true} regular last component={MyTextInput} />
              <Text>{this.state.errorText}</Text>
            </Body>
          </ListItem>
        </Content>
        <Footer>
          <Left>
            <Button light full>
            </Button>
          </Left>
          <Right>
            <Button onPress={handleSubmit} primary full style={{ width: '100%' }} disabled={invalid}>
              <Text style={{color: 'white', alignItems: 'center' }}>{I18n.t('next')}</Text>
            </Button>
          </Right>
        </Footer>
    </Container>
    );
  }
}

function mapStateToProps(state) {
  return {
    teams: state.teams,
    players: state.players,
    teamuid: getFormValues('AddGame')(state).teamuid,
    timezoneOfPlace: getFormValues('AddGame')(state).timezoneOfPlace,
    time: null,
    date: null,
    arriveearly: 0,
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
      homegame: true
    },
    validate: values => {
      const errors = {}

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

      if (values.place == '') {
        errors.place = I18n.t('needplace');
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
