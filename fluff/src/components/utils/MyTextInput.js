import React from 'react';
import { TextInput, View, Text } from 'react-native';
import { Item, Input, Label } from 'native-base';

/**
 * to be wrapped with redux-form Field component
 */
export default function MyTextInput(props) {
  const { input, title, defaultValue, ...inputProps } = props;

  console.log("Rendering text input ", input, title, ...inputProps);
  return (
      <Item {...inputProps} floatingLabel>
        <Label>{title}</Label>
        <Input onChangeText={input.onChange}
        onBlur={input.onBlur}
        onFocus={input.onFocus}
        value={defaultValue}
      />
      </Item>
  );
}
