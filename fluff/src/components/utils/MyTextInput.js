import React from 'react';
import { Item, Input, Label, Text, Textarea, Left, Body } from 'native-base';
import Icon from './Icon';
import styles from './styles';

/**
 * to be wrapped with redux-form Field component
 */
export default function MyTextInput(props) {
  const { input, meta, title, placeholder, multiline, numberOfLines,
    disableValid, rowspan, icon, ...inputProps } = props;
/*
  const formStates = ['active', 'autofilled', 'asyncValidating', 'dirty', 'invalid', 'pristine',
    'submitting', 'touched', 'valid', 'visited'];


  formStates.filter((state) => meta[state]).map((state) => {
    console.log(state);
  })

  */
  var renderError = meta.invalid && (meta.submitFailed || !meta.pristine);

  extra = null;
  if ((meta.submitFailed || !meta.pristine) && !disableValid) {
    if (meta.invalid) {
      inputProps.error = true
      extra = <Icon name='close-circle' />;
    } else {
      inputProps.success = true
      extra = <Icon name='checkmark-circle' />;
    }
  }
  if (multiline) {
    ret = (
        <Item {...inputProps}  >
          {title && <Label>{title}</Label>}

          <Textarea
            onChangeText={input.onChange}
            onBlur={input.onBlur}
            onFocus={input.onFocus}
            value={input.value}
            placeholder={placeholder}
            placeholderTextColor='#a7a7a7'
          />
          {extra}
        </Item>
      );
  } else {
    ret = (
        <Item {...inputProps}  >
          {icon && <Icon name={icon} />}
          {title && <Label>{title}</Label>}
          <Input
            onChangeText={input.onChange}
            onBlur={input.onBlur}
            onFocus={input.onFocus}
            value={input.value}
            placeholder={placeholder}
            multiline={multiline}
            numberOfLines={numberOfLines}
            placeholderTextColor='#a7a7a7'
          />
          {extra}
        </Item>
    );
  }
  console.log(ret);
  return ret;
}
