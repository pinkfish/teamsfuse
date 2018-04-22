import React from 'react';
import IconComm from 'react-native-vector-icons/MaterialCommunityIcons';
import IconMain from 'react-native-vector-icons/MaterialIcons';

export default function Icon(props) {
  const { name, ...inputProps } = props;

  if (name.startsWith('mat-')) {
    newName = name.substring(4);
    return <IconMain {...props} name={newName}  />;
  }
  return <IconComm name={name} {...props} />;
}
