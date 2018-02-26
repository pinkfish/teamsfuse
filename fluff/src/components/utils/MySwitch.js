import React from 'react';
import { Item, Label, Body, Right } from 'native-base';
import { Switch } from 'react-native';
import variables from '../../theme/variables/platform';
import styles from './styles';

/**
 * to be wrapped with redux-form Field component
 */
export default function MySwitch(props) {
  const { input, meta, title, ...inputProps } = props;
  var renderError = meta.invalid && (meta.submitFailed || !meta.pristine);

  extra = null;
  ret = (
      <Item {...inputProps} style={styles.item} >
        <Body style={styles.itemBody}>
          {title && <Label>{title}</Label>}
          <Right>
            <Switch
              style={styles.itemRightSwitch}
              onValueChange={(value) => { input.onChange(value) }}
              onBlur={input.onBlur}
              onFocus={input.onFocus}
              value={input.value}
            />
          </Right>
        </Body>
      </Item>
  );
  console.log(ret);
  return ret;
}
