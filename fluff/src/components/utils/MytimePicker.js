import React, { Component } from 'react';
import { Modal } from 'react-native';
import { Item, Text, Container, Content, Left, Body, Right } from 'native-base';
import Icon from './Icon';
import TimePickerInternal from './TimePickerInternal';
import styles from './styles';

export default class MyTimePicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
    };
  }


  openModal = () => {
    this.setState({modalVisible:true});
  }

  closeModal = () => {
    this.setState({modalVisible:false});
  }

  displayNiceTime = (date) => {
    // getHours returns the hours in local time zone from 0 to 23
    var hours = date.getHours()
    // getMinutes returns the minutes in local time zone from 0 to 59
    var minutes =  date.getMinutes()
    var meridiem = " AM"

    // convert to 12-hour time format
    if (hours > 12) {
      hours = hours - 12
      meridiem = ' PM'
    }
    else if (hours === 0){
      hours = 12
    }

    // minutes should always be two digits long
    if (minutes < 10) {
      minutes = "0" + minutes.toString()
    }
    return hours + ':' + minutes + meridiem
  }

  render() {
    const { options, title, input, meta, disableValid, ...inputProps } = this.props;

    if ((meta.submitFailed || !meta.pristine) && !disableValid) {
      if (meta.invalid) {
        inputProps.error = true
      } else {
        inputProps.success = true
      }
    }

    ret =
        <Item {...inputProps} icon onPress={this.openModal} style={styles.item}>
          <Left style={styles.itemLeft}>
            <Icon name="mat-access-time" />
          </Left>
          <Body style={styles.itemBody}>
            <TimePickerInternal input={input} visible={this.state.modalVisible} onClose={this.closeModal} />
            {input.value instanceof Date && <Text>{this.displayNiceTime(input.value)}</Text>}
            {!(input.value instanceof Date) && <Text note>{this.props.title}</Text>}
          </Body>
          <Right style={styles.itemRight}>
            <Icon name='mat-chevron-right' />
          </Right>
        </Item>;

    return ret;
  }
}
