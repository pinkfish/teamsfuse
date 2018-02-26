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
  Radio
} from "native-base";
import { Image, View, DatePickerIOS } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';
import { Field, reduxForm, submit } from 'redux-form'
import MyPicker from "../../utils/MyPicker";
import MyCheckbox from "../../utils/MyCheckbox";
import MySwitch from '../../utils/MySwitch';
import MyDatePicker from "../../utils/MyDatePicker";
import FormRefComponent from '../../utils/FormRefComponent';

const HOW_OFTEN_LIST = [
    {
      title: 'Weekly',
      key: 'weekly'
    },
    {
      title: 'Days of Week',
      key: 'daysofweek'
    },
  ];


class AddGame1 extends FormRefComponent {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: '',
         selected: 'game',
         chosenDate: new Date()
    }
    this.radio = {}

    this.setDate = this.setDate.bind(this);
  }

  setRadio = (state) => {
    const { change } = this.props;

    change('type', state);
    this.setState({ selected: state });
  }

  setDate(newDate) {
    this.setState({chosenDate: newDate})
  }

  render() {
    const { handleSubmit, players, teams } = this.props;

    return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="repeat" title={I18n.t('repeat')} component={MySwitch} />
              <Field name="howoften" title={I18n.t('howoften')} component={MyPicker} options={HOW_OFTEN_LIST} />
              <Field name="until" title={I18n.t('until')} component={MyDatePicker} />
              <Field name="monday" title={I18n.t('monday')} component={MyCheckbox} disabled />
              <Field name="tuesday" title={I18n.t('tuesday')} component={MyCheckbox} disabled />
              <Field name="wednesday" title={I18n.t('wednesday')} component={MyCheckbox} disabled />
              <Field name="thursday" title={I18n.t('thursday')} component={MyCheckbox} disabled />
              <Field name="friday" title={I18n.t('friday')} component={MyCheckbox} disabled />
              <Field name="saturday" title={I18n.t('saturday')} component={MyCheckbox} disabled />
              <Field name="sunday" title={I18n.t('sunday')} component={MyCheckbox} disabled />
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
    teams: state.teams,
    players: state.players
  }
}

const enhance = compose(
  reduxForm({
    form: 'AddGame',
    destroyOnUnmount: false, // Preserve the data.
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
  connect(mapStateToProps)
  );


export default enhance(AddGame1);
