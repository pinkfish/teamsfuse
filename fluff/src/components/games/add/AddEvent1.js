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

  checkThenNext = (handleSubmit) {
  }

  render() {
    const { handleSubmit, players, teams, navigation, error, teamuid, timezoneOfPlace, invalid } = this.props;

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

    return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="teamuid" title={I18n.t('teamselect')} component={TeamListPicker} teams={teams} />
              <Field name="name" title={I19n.t('eventname')} component={MyTextInput} regular />
              <Separator />
              <Field name="time" title={I18n.t('eventtime')} component={MyTimePicker} />
              <Field name="date" title={I18n.t('eventdate')} component={MyDatePicker} />
              <Field name="duration" title={I18n.t('duration')} component={MyDurationPicker} />
              <Separator />
              <Field name="place" title={I18n.t('eventplace')} component={MyPlacePicker} onFormChange={this.onPlaceChange} />
              <Field name="placenotes" placeholder={I18n.t('placenotes')} multiline={true} regular component={MyTextInput} />
              <Separator />
              <Field name="notes" placeholder={I18n.t('notes')} multiline={true} component={MyTextInput} regular />
              <Text>{this.state.errorText}</Text>
            </Body>
          </ListItem>
        </Content>
        <Footer style={{ height: 50 }}>
          <Left>
            <Button full light/>
          </Left>
          <Right>
            <Button onPress={handleSubmit} disabled={invalid} full primary>
              <Text>{I18n.t('next')}</Text>
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
    teamuid: getFormValues('AddEvent')(state).teamuid,
  }
}

const enhance = compose(
  reduxForm({
    form: 'AddEvent',
    destroyOnUnmount: false, // Preserve the data.
    initialValues: {
      name: '',
      teamuid: '',
    },
    validate: values => {
      const errors = {}

      //values = values.toJS()

      if (!values.teamuid) {
        errors.name = I18n.t('needteam')
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
