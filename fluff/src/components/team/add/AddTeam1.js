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
  Thumbnail
} from "native-base";
import { Image } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import styles from './styles';
import { Field, reduxForm, submit } from 'redux-form'
import MyTextInput from "../../utils/MyTextInput";
import MyPicker from "../../utils/MyPicker";

class AddTeamPageOne extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }


  render() {
    const { handleSubmit, players } = this.props;

    return (
      <Container>
        <Content>
          <ListItem style={styles.container} key='4'>
            <Body>
              <Text>Select player</Text>
              <Field name="playeruid" component={MyPicker} mode="dropdown" defaultValue='other' regular styles={{height: 60}}c>
                {players && players.list.map((player) => {
                    return (
                        <Item label={player.name} value={player.uid} key={player.uid} />
                    );
                })}
              </Field>
              <Text>{this.state.errorText}</Text>
              <Button light>
                <Text>{I18n.t('newplayer')}</Text>
              </Button>
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
    players: state.players,
    initialValues: {
      sport: 'other',
      timezone: 'PST',
      country: 'us',
      gender: 'na',
      season: new Date().getFullYear()
    }
  }
}

const enhance = compose(
  reduxForm({
    form: 'AddTeam',
    destroyOnUnmount: false, // Preserve the data.
    validate: values => {
      const errors = {}
      console.log('validate teams p1', values)

      //values = values.toJS()

      if (!values.playeruid) {
        errors.name = I18n.t('needteamname')
      }

      // Do the actual login here.
      return errors
    },
    onSubmit: values => {
    },
  }),
  connect(mapStateToProps)
  );


export default enhance(AddTeamPageOne);
