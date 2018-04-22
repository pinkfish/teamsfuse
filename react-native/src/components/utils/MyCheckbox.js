import React from 'react';
import { Item, Label, Body, CheckBox } from 'native-base';
import styles from './styles';

/**
 * to be wrapped with redux-form Field component
 */
export default function MyCheckbox(props) {
  const { input, meta, title, ...inputProps } = props;
  var renderError = meta.invalid && (meta.submitFailed || !meta.pristine);

  extra = null;
  ret = (
      <Item {...inputProps} style={styles.item} >
        <CheckBox
          onPress={(input) => { input.onChange(!input.checked) }}
          onBlur={input.onBlur}
          onFocus={input.onFocus}
          checked={input.value}
        />
        <Body>
          {title && <Label>{title}</Label>}
        </Body>
      </Item>
  );
  console.log(ret);
  return ret;
}
