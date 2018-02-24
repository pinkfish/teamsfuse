import React, { Component } from 'react';
import { View, Modal } from 'react-native';
import { Label, ListItem, Text, List, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import WheelPicker from 'react-native-wheel-picker';

export default class MyPicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
      itemList: [ 0, 5,  10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 240 ]
    };
  }


  openModal = () => {
    this.setState({modalVisible:true});
  }

  closeModal = () => {
    this.setState({modalVisible:false});
  }

  showValue = () => {
    const { options, input } = this.props;

    return '' + input.value + ' ' + I18n.t('minutes');
  }

  render() {
    const { options, title, input, disabled, ...inputProps } = this.props;

    ret =
        <ListItem {...inputProps} icon onPress={disabled ? () => {}: this.openModal}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title} onLeftPress={this.closeModal}/>
              <Content>
                <WheelPicker
                  selectedvalue={input.value}
                  onValueChange={input.onChange}
                  >
                  {this.state.itemList.map((value, i) => (
                      <PickerItem label={value} value={value} key={"duration"+value}/>
                    ))}
                </WheelPicker>
              </Content>
            </Container>
          </Modal>
          <Body>
            {input.value != '' && <Text>{this.showValue()}</Text>}
            {input.value == '' && <Text note>{title}</Text>}
          </Body>
          <Right>
            <Icon name='mat-chevron-right' />
          </Right>
        </ListItem>;
    console.log('ret', ret);

    return ret;
  }
}
