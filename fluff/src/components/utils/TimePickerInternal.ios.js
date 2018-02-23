import React from 'react';
import { DatePickerIOS } from 'react-native';

export default function(props) {
  const { input, visible, onClose } = props;

  if (value instanceof Date) {
    displayValue = input.value;
  } else {
    displayValue = new Date();
  }

  return <Modal
      visible={visible}
      animationType={'slide'}
      onRequestClose={onClose}
      >
    <Container>
      <ModalHeader title={title}  onLeftPress={onClose} iconRight='check' onRightPress={onClose} />
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
