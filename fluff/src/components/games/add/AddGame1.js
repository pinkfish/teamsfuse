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
import MyCheckbox from "../../utils/MyCheckbox";
import TimeZonePicker from "../../utils/TimeZonePicker"
import { withNavigation } from 'react-navigation';

class AddGame1 extends Component {
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
    const { handleSubmit, players, teams, navigation, error, teamuid, timezoneOfPlace } = this.props;

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
              <Field name="name" placeholder={I18n.t('gamename')} component={MyTextInput} visible={false} />
              <Field name="teamuid" title={I18n.t('teamselect')} component={TeamListPicker} teams={teams} />
              <Field name="opponentuid"
                title={teamuid != '' ? I18n.t('eventopponent') : I18n.t('teamselectfirst')}
                disabled={teamuid == ''}
                component={MyPicker}
                options={opponentList}
                onUpdate={teamuid == 'add' ? this.addOpponent() : () => {}}
              />
              <Separator />
              <Field name="time" title={I18n.t('eventtime')} component={MyTimePicker} />
              <Field name="date" title={I18n.t('eventdate')} component={MyDatePicker} />
              <Field name="place" title={I18n.t('eventplace')} component={MyPlacePicker} onFormChange={this.onPlaceChange} />
              <Field name="placenotes" placeholder={I18n.t('placenotes')} multiline={true} regular component={MyTextInput} />
              <Field name="timezoneOfPlace" title={I18n.t('timezoneofplace')} component={MyCheckbox} regular />
              <Field name="timezone" title={I18n.t('timezone')} component={TimeZonePicker} visible={!timezoneOfPlace} regular placeholderLabel />
              <Separator />
              <Field name="uniform" placeholder={I18n.t("Uniform")} component={MyTextInput} regular />
              <Separator />
              <Field name="notes" placeholder={I18n.t('notes')} multiline={true} component={MyTextInput} regular />
              <Text>{this.state.errorText}</Text>
            </Body>
          </ListItem>
        </Content>
        <Footer style={{ height: 50 }}>
          <Left>

          </Left>
          <Right>
            <Button onPress={handleSubmit} block primary>
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
    teamuid: getFormValues('AddGame')(state).teamuid,
    timezoneOfPlace: getFormValues('AddGame')(state).timezoneOfPlace,
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
      timezone: I18n.t('unknown'),
      timezoneOfPlace: true
    },
    validate: values => {
      const errors = {}
      console.log('validate teams p1', values)

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
