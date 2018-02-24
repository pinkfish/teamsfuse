import React from 'react';
import { DatePickerIOS } from 'react-native';
import { Modal } from 'react-native';
import { Container, Content } from 'native-base';
import { ModalHeader } from '../app/AppHeader';

export default function(props) {
  const { input, visible, onClose } = props;

  if (input.value instanceof Date) {
    displayValue = input.value;
  } else {
    displayValue = new Date();
  }
  oldValue = input.value;

  return <Modal
      visible={visible}
      animationType={'slide'}
      onRequestClose={onClose}
      >
    <Container>
      <ModalHeader title={input.title} onLeftPress={onClose} iconRight='check' onRightPress={onClose} />
      <Content>
        <DatePickerIOS
          date={displayValue}
          onDateChange={input.onChange}
          mode='time'
          minuteInterval={5}
        />
      </Content>
    </Container>
  </Modal>;
}
