import React, { Component } from 'react';
import { Modal } from 'react-native';
import { ListItem, Text, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import TimePickerInternal from './TimePickerInternal';

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
    const { options, title, input, ...inputProps } = this.props;
    ret =
        <ListItem {...inputProps} icon onPress={this.openModal}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title}  onLeftPress={this.closeModal} />
              <Content>
                <TimePickerInternal value={input.value} onChange={input.onChange}/>
              </Content>
            </Container>
          </Modal>
          <Body>
            {input.value instanceof Date && <Text>{this.displayNiceTime(input.value)}</Text>}
            {!(input.value instanceof Date) && <Text note>{title}</Text>}
          </Body>
          <Right>
            <Icon name='mat-chevron-right' />
          </Right>
        </ListItem>;
    console.log('ret', ret);

    return ret;
  }
}
