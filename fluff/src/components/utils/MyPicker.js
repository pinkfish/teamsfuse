import React from 'react';
import { View } from 'react-native';
import { Picker, Label, Item, Text } from 'native-base';

export default renderPicker = ({ input: { onChange, value, ...inputProps }, children, title, ...pickerProps }) => (
  <Item>
    <Label>{title}</Label>
    <Picker
      selectedValue={ value }
      onValueChange={ value => onChange(value) }
      { ...inputProps }
      { ...pickerProps }
    >
      { children }
    </Picker>
  </Item>
);
