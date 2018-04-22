import React from 'react';
import MyPicker from '../utils/MyPicker';

export default teamListPicker = (props) => {
  const { teams, title, input, ...inputProps } = props;

  optionList = [];
  for (key in teams.list) {
    if (teams.list.hasOwnProperty(key)) {
      team = teams.list[key];
      optionList.push({ title: team.name, key: team.uid })
   }
 }

  return <MyPicker icon="mat-people" title={title} options={optionList} input={input} {...inputProps} />
}
