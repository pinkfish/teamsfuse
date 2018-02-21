/*
 * Action types.
 */
export const SET_CURRENT_TEAM = "SET_CURRENT_TEAM";
export const FETCH_TEAM_DATA_SUCCESS = "FETCH_TEAM_DATA_SUCCESS";
export const FETCH_TEAM_DATA_FAILURE = "FETCH_TEAM_DATA_FAILURE";
export const FETCH_TEAM_DATA = "FETCH_TEAM_DATA";
export const FETCH_TEAM_DATA_CANCEL = "FETCH_TEAM_DATA_CANCEL";
export const FETCH_TEAM_DATA_ADD = "FETCH_TEAM_DATA_ADD";
export const FETCH_TEAM_DATA_DELETE = "FETCH_TEAM_DATA_DELETE";
export const FETCH_TEAM_DATA_UPDATE = "FETCH_TEAM_DATA_UPDATE";
export const FETCH_TEAM_DATA_SINGLE = "FETCH_TEAM_DATA_SINGLE";


/*
* Action creators.
*/
export function setTeam(team) {
  return { type: SET_CURRENT_TEAM, team }
}

export function fetchTeamDataSuccess(allPlayers) {
  return { type: FETCH_TEAM_DATA_SUCCESS, payload: allPlayers }
}

export function fetchTeamDataFailure(uid) {
  return { type: FETCH_TEAM_DATA_FAILURE, payload: uid }
}

export function fetchTeamData() {
  return { type: FETCH_TEAM_DATA, payload: {} }
}

export function fetchTeamDataAdd(team) {
  return { type: FETCH_TEAM_DATA_ADD, team }
}

export function fetchTeamDataDelete(team) {
  return { type: FETCH_TEAM_DATA_DELETE, team }
}

export function fetchTeamDataUpdate(team) {
  return { type: FETCH_TEAM_DATA_UPDATE, team }
}

export function fetchTeamDataSingle(teamUid) {
  return { type: FETCH_TEAM_DATA_SINGLE, teamUid }
}
