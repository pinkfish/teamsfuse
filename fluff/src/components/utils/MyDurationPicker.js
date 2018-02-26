import React, { Component } from 'react';
import { View, Modal } from 'react-native';
import { Label, Item, Text, List, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import styles from "./styles";

const ITEM_LIST = [ 0, 5,  10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 240 ];

export default class MyDurationPicker extends Component {
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

  renderItem = (item) => {
    const { input } = this.props;
    return <Item key={'time' + item} onPress={() => this.selectItem(item)} icon style={styles.item}>
            <Left style={styles.itemLeft}></Left>
            <Body style={styles.itemBody}>
               <Text>{item}</Text>
             </Body>
             {item == input.value && <Right style={styles.itemRight}><Icon name='mat-check'/></Right>}
          </Item>
  }

  showValue = () => {
    const { options, input } = this.props;

    return '' + input.value + ' ' + I18n.t('minutes');
  }

  render() {
    const { options, title, input, disabled, icon, ...inputProps } = this.props;

    ret =
        <Item {...inputProps} icon onPress={disabled ? () => {}: this.openModal} style={styles.item}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title} onLeftPress={this.closeModal}/>
              <Content>
                <List>
                  {ITEM_LIST.forEach((value) => (this.renderItem(value)))}
                </List>
              </Content>
            </Container>
          </Modal>
          <Left style={styles.itemLeft}>
            <Icon name="calendar-range" />
          </Left>
          <Body style={styles.itemBody}>
            {input.value != '' && <Text>{this.showValue()}</Text>}
            {input.value == '' && <Text note>{title}</Text>}
          </Body>
          <Right style={styles.itemRight}>
            <Icon name='mat-chevron-right' />
          </Right>
        </Item>;
    console.log('ret', ret);

    return ret;
  }
}
