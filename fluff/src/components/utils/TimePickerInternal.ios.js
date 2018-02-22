import React from 'react';
import { DatePickerIOS } from 'react-native';

export default function(props) {
  const { value, onChange } = props;

  if (value instanceof Date) {
    displayValue = value;
  } else {
    displayValue = new Date();
  }
  return <DatePickerIOS
    date={displayValue}
    onDateChange={onChange}
    mode='time'
    minuteInterval={5}
  />

}
