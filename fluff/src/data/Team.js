// Bunch of utility functions to deal with teams.

export function getTeam(teams, teamuid) {
  if (teams.list.hasOwnProperty(teamuid)) {
    return teams.list[teamuid];
  }
  return null;
}

export function getSeasons(team, players) {
  seasonsRet = {};
  for (playeruid in players.list) {
    seasons = team.seasons;
    for (key in seasons) {
      if (seasons[key].player.hasOwnProperty(playeruid)) {
        seasonsRet[key] = true;
      }
    }
  }
  retList = [];
  for (key in seasons) {
    val = team.seasons[key];
    val.uid = key;
    retList.push(val);
  }
  return retList;
}
