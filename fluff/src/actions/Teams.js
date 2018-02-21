/*
 * Action types.
 */
export const SET_CURRENT_TEAM = "SET_CURRENT_TEAM";
export const FETCH_TEAM_DATA_SUCCESS = "FETCH_TEAM_DATA_SUCCESS";
export const FETCH_TEAM_DATA_FAILURE = "FETCH_TEAM_DATA_FAILURE";
export const FETCH_TEAM_DATA = "FETCH_TEAM_DATA";
export const FETCH_TEAM_DATA_CANCEL = "FETCH_TEAM_DATA_CANCEL";


/*
* Action creators.
*/
export function setTeam(team) {
 return { type: SET_CURRENT_TEAM, team }
}

export function fetchTeamDataSuccess(allPlayers) {
  return { type: FETCH_TEAM_DATA_SUCCESS, payload: allPlayers }
}

export function fetchTeamDataFailure() {
  return { type: FETCH_TEAM_DATA_FAILURE, payload: {} }
}

export function fetchTeamData() {
  return { type: FETCH_TEAM_DATA, payload: {} }
}
