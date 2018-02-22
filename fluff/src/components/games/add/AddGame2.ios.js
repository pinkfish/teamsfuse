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
import MyTextInput from "../../utils/MyTextInput";
import MyPicker from "../../utils/MyPicker";
import MyRadioGroup from "../../utils/MyRadioGroup";

class AddGame1 extends Component {
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
              <View>
                <DatePickerIOS
                  date={this.state.chosenDate}
                  mode='datetime'
                  minuteInterval={5}
                  onDateChange={this.setDate}
                />
              </View>
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
