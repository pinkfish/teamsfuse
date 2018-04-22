import React from 'react';
import { Item, Label, Body, Button } from 'native-base';
import styles from './styles';

/**
 * to be wrapped with redux-form Field component
 */
export default function MyRoundButton(props) {
  const { input, meta, title, ...inputProps } = props;
  var renderError = meta.invalid && (meta.submitFailed || !meta.pristine);

  extra = null;
  if (input.value) {
    styleToApply = {
      ...styles.roundButton,
      ...styles.roundButtonSelected,
    }
    buttonStyle = styles.roundButtonLabelSelected;
  } else {
    styleToApply = styles.roundButton;
    buttonStyle = styles.roundButtonLabel;
  }
  ret = (
        <Button
          style={styleToApply}
          onPress={() => { input.onChange(!input.value) }}
          onBlur={input.onBlur}
          onFocus={input.onFocus}
          checked={input.value}
          {...inputProps} >
          {title && <Label style={buttonStyle}>{title}</Label>}
        </Button>
  );
  return ret;
}
