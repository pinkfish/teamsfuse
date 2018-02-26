import React from 'react';
import { View } from 'react-native';
import { Picker, Label, Item, Text } from 'native-base';
import styles from './styles';

export default renderRadio = ({ input: { onChange, value, ...inputProps }, children, title, ...pickerProps }) => {
  children.map((item) => {
    item.onPress=() => { onChange(item.key) };
  });

  return <Item style={styles.item}>
    <Label>{title}</Label>
    {children}
  </Item>
};
