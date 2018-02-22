import React from 'react';
import { View } from 'react-native';
import { Picker, Label, Item, Text } from 'native-base';

export default renderRadio = ({ input: { onChange, value, ...inputProps }, children, title, ...pickerProps }) => {
  children.map((item) => {
    item.onPress=() => { onChange(item.key) };
  });

  return <Item>
    <Label>{title}</Label>
    {children}
  </Item>
};
