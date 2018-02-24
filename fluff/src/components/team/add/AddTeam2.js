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
import MyDurationPicker from '../../utils/MyDurationPicker';

class AddTeamPageOne extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }


  render() {
    const { handleSubmit, previousPage } = this.props;

    return (
      <Container>
        <Content>
          <ListItem style={styles.container} key='4'>
            <Body>
              <Field name="name" title={I18n.t('teamname')} component={MyTextInput} floatingLabel />
              <Field name="league" title={I18n.t('league')} component={MyTextInput} floatingLabel disableValid={true} />
              <Field name="sport" title={I18n.t('sport')} component={MyPicker} mode="dropdown" defaultValue='other' regular styles={{height: 60}}c>
                <Item label={I18n.t('basketball')} value='basketball' />
                <Item label={I18n.t('soccer')} value='soccer' />
                <Item label={I18n.t('lacross')} value='lacross' />
                <Item label={I18n.t('rugby')} value='rugby' />
                <Item label={I18n.t('cricket')} value='cricket' />
                <Item label={I18n.t('softball')} value='softball' />
                <Item label={I18n.t('baseball')} value='baseball' />
                <Item label={I18n.t('football')} value='football' />
                <Item label={I18n.t('other')} value='other' />
              </Field>
              <Field name="gender" title={I18n.t('gender')} component={MyPicker} styles={{height: 60}}>
                <Item label={I18n.t('genderfemale')} value='female' />
                <Item label={I18n.t('gendermale')} value='male' />
                <Item label={I18n.t('gendercoed')} value='coed' />
                <Item label={I18n.t('genderna')} value='na' />
              </Field>
              <Separator />
              <Field name="defaultearlyarrival" component={MyDurationPicker} title={I18n.t('defaultearlyarrival')} />
              <Text>{this.state.errorText}</Text>
            </Body>
          </ListItem>
        </Content>
        <Footer style={{ height: 50 }}>
          <Left>
            <Button onPress={previousPage} block light>
              <Text>{I18n.t('previous')}</Text>
            </Button>
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

const enhance = compose(
  reduxForm({
    form: 'AddTeam',
    destroyOnUnmount: false, // Preserve the data.
    validate: values => {
      const errors = {}
      console.log('validate teams p1', values)

      //values = values.toJS()

      if (!values.name) {
        errors.name = I18n.t('needteamname')
      }

      // Do the actual login here.
      return errors
    },
    onSubmit: values => {
    },
  })
  );


export default enhance(AddTeamPageOne);
