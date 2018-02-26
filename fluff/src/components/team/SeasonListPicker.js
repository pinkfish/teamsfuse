import React from 'react';
import MyPicker from '../utils/MyPicker';

export default SeasonListPicker = (props) => {
  const { teams, title, input, teamuid, ...inputProps } = props;

  if (input.value == '' && teams.list.hasOwnProperty(teamuid)) {
    input.value = item;
  }
  optionList = [];
  if (teams.list.hasOwnProperty(teamuid)) {
    item = ''
    team = teams.list[teamuid];
    for (key in team.seasons) {
      if (team.seasons[key].current) {
        item = key;
      }
      optionList.push({ title: team.seasons[key].name, key: key })
    }
    if (input.value == '') {
      input.value = item;
    }
 }

  return <MyPicker icon="mat-people" title={title} options={optionList} input={input} {...inputProps} />
}
