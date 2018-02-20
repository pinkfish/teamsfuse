import React from 'react';
import { TextInput, View, Text } from 'react-native';
import { Item, Input, Label } from 'native-base';

/**
 * to be wrapped with redux-form Field component
 */
export default function MyTextInput(props) {
  const { input, meta, title, ...inputProps } = props;

  const formStates = ['active', 'autofilled', 'asyncValidating', 'dirty', 'invalid', 'pristine',
    'submitting', 'touched', 'valid', 'visited'];

  console.log("Rendering text input ", input, title, ...inputProps);

  formStates.filter((state) => meta[state]).map((state) => {
    console.log(state);
  })

  return (
      <Item {...inputProps} floatingLabel>
        <Label>{title}</Label>
        <Input onChangeText={input.onChange}
          onBlur={input.onBlur}
          onFocus={input.onFocus}
          value={input.value}
        />
        {props.touched && props.error && <Text>{props.error}</Text>}
        </Item>
  );
}
