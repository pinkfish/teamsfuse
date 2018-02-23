import React, { Component } from 'react';
import { Modal } from 'react-native';
import { ListItem, Text, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import DatePickerInternal from './DatePickerInternal';

export default class MyDatePicker extends Component {
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

  displayNiceDate = (date) => {
    return date.toLocaleDateString([], { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
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
              <ModalHeader title={title}  onLeftPress={this.closeModal} iconRight='check' onRightPress={this.closeModal} />
              <Content>
                <DatePickerInternal value={input.value} onChange={input.onChange}/>
              </Content>
            </Container>
          </Modal>
          <Body>
            {input.value instanceof Date && <Text>{this.displayNiceDate(input.value)}</Text>}
            {!(input.value instanceof Date) && <Text note>{title}</Text>}
          </Body>
          <Right>
            <Icon name='mat-chevron-right' />
          </Right>
        </ListItem>;

    return ret;
  }
}
