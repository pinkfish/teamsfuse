import React, { Component } from 'react';
import { Modal } from 'react-native';
import { Item, Text, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import DatePickerInternal from './DatePickerInternal';
import styles from './styles';

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
          <Left style={styles.itemLeft}>
            <Icon name="calendar" style={styles.iconstart} />
          </Left>
          <Body style={styles.itemBody}>
            {input.value instanceof Date && <Text>{this.displayNiceDate(input.value)}</Text>}
            {!(input.value instanceof Date) && <Text note>{title}</Text>}
          </Body>
          <Right style={styles.itemRight}>
            <Icon name='mat-chevron-right' style={styles.iconend} />
          </Right>
        </Item>;

    return ret;
  }
}
