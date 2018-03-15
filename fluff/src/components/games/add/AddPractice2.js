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
import { Field, reduxForm, submit, getFormValues } from 'redux-form'
import MyPicker from "../../utils/MyPicker";
import MyCheckbox from "../../utils/MyCheckbox";
import MySwitch from '../../utils/MySwitch';
import MyDatePicker from "../../utils/MyDatePicker";
import MyTextInput from "../../utils/MyTextInput";
import MyRoundButton from "../../utils/MyRoundButton";
import FormRefComponent from '../../utils/FormRefComponent';

const HOW_OFTEN_LIST = [
    {
      title: I18n.t('month'),
      key: 'monthly',
    },
    {
      title: I18n.t('week'),
      key: 'week',
    },
  ];


class AddPractice2 extends FormRefComponent {
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
    const { handleSubmit, players, teams, howoften, repeat } = this.props;

    return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="repeat" title={I18n.t('repeat')} component={MySwitch} noborder />

              {repeat &&
                  <Item style={{ borderBottomWidth: 0 }}>
                  <Body style={{ flexDirection: 'row', borderBottomWidth: 0 }}>
                    <Text>{I18n.t('repeatevery')}</Text>
                    <Field name='interval' component={MyTextInput} number fixedLabel
                       style={{ width: 50 }}/>
                    <Field name="howoften" component={MyPicker} options={HOW_OFTEN_LIST} title={I18n.t('howoften')} />
                  </Body>
                </Item>
              }

              {howoften == 'week' && repeat ?
                  <Item style={{ flexDirection: 'row', borderBottomWidth: 0, width: '100%', justifyContent: 'space-between'}}>
                    <Field name="monday" title={I18n.t('mondayletter')} component={MyRoundButton} rounded inline />
                    <Field name="tuesday" title={I18n.t('tuesdayletter')} component={MyRoundButton} rounded inline />
                    <Field name="wednesday" title={I18n.t('wednesdayletter')} component={MyRoundButton} rounded inline />
                    <Field name="thursday" title={I18n.t('thursdayletter')} component={MyRoundButton} rounded inline  />
                    <Field name="friday" title={I18n.t('fridayletter')} component={MyRoundButton} rounded inline />
                    <Field name="saturday" title={I18n.t('saturdayletter')} component={MyRoundButton} rounded inline />
                    <Field name="sunday" title={I18n.t('sundayletter')} component={MyRoundButton} rounded inline />
                  </Item>
                : null }
              {repeat && <Field name="until" title={I18n.t('until')} component={MyDatePicker} />}
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
    players: state.players,
    howoften: getFormValues('AddPractice')(state).howoften,
    repeat: getFormValues('AddPractice')(state).repeat
  }
}

const enhance = compose(
  reduxForm({
    form: 'AddPractice',
    destroyOnUnmount: false, // Preserve the data.
    initialValues: {
      interval: 1,
      howoften: 'week',
      repeat: false,
      monday: false,
      tuesday: false,
      wednesday: true,
      thursday: false,
      friday: false,
      saturday: false,
      sunday: false,
    },
    validate: values => {
      const errors = {}
  
      if (values.repeat && values.howoften == 'unknown') {
        errors.unknown = I18n.t('needrepeat');
      }

      return errors
    },
    onSubmit: values => {
    },
  }),
  connect(mapStateToProps)
  );


export default enhance(AddPractice2);
