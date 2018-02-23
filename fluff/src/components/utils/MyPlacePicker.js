import React, { Component } from 'react';
import { Modal } from 'react-native';
import { ListItem, Text, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import RNGooglePlaces from 'react-native-google-places';

export default class MyDatePicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
    };
  }


  openModal = () => {
    const { onChange } = this.props.input;
    RNGooglePlaces.openPlacePickerModal()
    .then((place) => {
  		console.log(place);
  		// place represents user's selection from the
  		// suggestions and it is a simplified Google Place object.
      onChange(place);
    })
    .catch(error => console.log(error.message));  // error is a Javascript Error object
  }

  closeModal = () => {
  }

  render() {
    const { options, title, input, ...inputProps } = this.props;
    ret =
        <ListItem {...inputProps} icon onPress={this.openModal}>
          <Body>
            {input.value != '' && <Text>{input.value.name} ({input.value.address})</Text>}
            {(input.value == '') && <Text note>{title}</Text>}
          </Body>
          <Right>
            <Icon name='mat-chevron-right' />
          </Right>
        </ListItem>;

    return ret;
  }
}
