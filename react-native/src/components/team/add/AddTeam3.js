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
import { withNavigation } from 'react-navigation';
import { getFormValues } from 'redux-form';


class AddTeamPageThree extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  render() {
    const { handleSubmit, formValues, previousPage } = this.props;
    console.log('stuff', this.props);

    return (
      <Container>
        <Content style={{ flex: 1, backgroundColor: "#fff", top: -1 }}>
          <ListItem style={styles.container} key='1'>
            <Body>
              <Text>{I18n.t('createteam')}</Text>
              <Text>{formValues.name} - {I18n.t(formValues.sport)} </Text>
              <Text>{formValues.league}</Text>
              <Text>{formValues.description}</Text>
              <Text>{formValues.gender} {formValues.age}</Text>
            </Body>
          </ListItem>
          </Content>
        <Footer>
          <Left>
            <Button onPress={previousPage} block light>
              <Text>{I18n.t('previous')}</Text>
            </Button>
          </Left>
          <Right>
            <Button onPress={handleSubmit} block success>
              <Text>{I18n.t('addteam')}</Text>
            </Button>
          </Right>
        </Footer>
      </Container>
    );
  }
}

const mapStateToProps = (state, props) => {
    // ...some irrelevant logic
    return {
        formValues: getFormValues('AddTeam')(state),
    };
};
const enhance = compose(
  reduxForm({
    form: 'AddTeam',
    destroyOnUnmount: false, // Preserve the data.
    validate: values => {
      const errors = {}
      console.log(values)

      // Do the actual login here.
      return errors
    },
    onSubmit: values => {
    },
  }),
  connect(mapStateToProps)
  );


export default enhance(AddTeamPageThree);
