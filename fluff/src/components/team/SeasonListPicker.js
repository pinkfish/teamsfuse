import React from 'react';
import MyPicker from '../utils/MyPicker';
import { getTeam, getSeasons } from "../../data/Team";

export default SeasonListPicker = (props) => {
  const { teams, title, input, teamuid, players, ...inputProps } = props;

  team =  getTeam(teams, teamuid);
  optionList = [];
  if (team != null) {
    item = ''
    seasons = getSeasons(team, players);
    for (key in team.seasons) {
      if (key == team.currentSeason) {
        item = key;
      }
      optionList.push({ title: team.seasons[key].name, key: key })
    }
    if (input.value == '') {
      input.value = item;
    }
 }

 console.log('players', teams, optionList);
  return <MyPicker icon="mat-people" title={title} options={optionList} input={input} {...inputProps} />
}
