import React, { Component } from 'react';
import { Modal } from 'react-native';
import { ListItem, Text, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import RNGooglePlaces from 'react-native-google-places';

const URL = "https://maps.googleapis.com/maps/api/timezone/json?location=";
const KEY = "AIzaSyCP22ZMhWoQuzH9qIEnxYL7C_XfjWjo6tI";

export default class MyDatePicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
    };
  }

  lookupPlaceToTimezone = (place) => {
    const { onChange } = this.props.input;

    url = URL + place.latitude + "," + place.longitude + "&key=" + KEY
        + "&timestamp=" + (Date.now() / 1000);
    return fetch(url)
        .then((response) => response.json())
        .then((responseJson) => {
           place.timeZoneId = responseJson.timeZoneId;
           place.timeZoneName = responseJson.timeZoneName;
           onChange(place);
           if (this.props.onFormChange) {
             this.props.onFormChange(place);
           }
        })
        .catch((error) => {
          console.log('error getting tz', error);
          onChange(place);
          if (this.props.onFormChange) {
            this.props.onFormChange(place);
          }
        });
  }


  openModal = () => {
    const { onChange } = this.props.input;
    RNGooglePlaces.openPlacePickerModal()
    .then((place) => {
  		console.log(place);
  		// place represents user's selection from the
  		// suggestions and it is a simplified Google Place object.
      this.lookupPlaceToTimezone(place);
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
