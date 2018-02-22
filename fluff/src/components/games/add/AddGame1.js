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
import { Image, View } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';
import { Field, reduxForm, submit } from 'redux-form'
import MyTextInput from "../../utils/MyTextInput";
import MyPicker from "../../utils/MyPicker";
import MyRadioGroup from "../../utils/MyRadioGroup";
import MyTimePicker from "../../utils/MytimePicker";
import MyDatePicker from "../../utils/MyDatePicker";
import { withNavigation } from 'react-navigation';

class AddGame1 extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: '',
         selected: 'game'
    }
    this.radio = {}
  }

  setRadio = (state) => {
    const { change } = this.props;

    change('type', state);
    this.setState({ selected: state });
  }

  render() {
    const { handleSubmit, players, teams, navigation, error } = this.props;

    optionList = [];
    teams.list.map((team) => {
       optionList.push({ title: team.name, key: team.uid })
    })

    return (
      <Container>
        <Content>
          <ListItem style={styles.main} key='4'>
            <Body>
              <Field name="name" component={MyTextInput} regular placeholder={I18n.t('gamename')} />
              <Field name="teamuid" title={I18n.t('teamselect')} component={MyPicker} options={optionList} />
              <Field name="time" title={I18n.t('eventtime')} component={MyTimePicker} />
              <Field name="date" title={I18n.t('eventdate')} component={MyDatePicker} />
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
    players: state.players
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
