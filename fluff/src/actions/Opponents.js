/*
 * Action types.
 */
export const FETCH_OPPONENT_DATA_SUCCESS = "FETCH_OPPONENT_DATA_SUCCESS";
export const FETCH_OPPONENT_DATA_FAILURE = "FETCH_OPPONENT_DATA_FAILURE";
export const FETCH_OPPONENT_DATA = "FETCH_OPPONENT_DATA";
export const FETCH_OPPONENT_DATA_CANCEL = "FETCH_OPPONENT_DATA_CANCEL";


/*
* Action creators.
*/
export function fetchOpponentDataSuccess(team, allPlayers) {
  return { type: FETCH_OPPONENT_DATA_SUCCESS, team: team, payload: allPlayers }
}

export function fetchOpponentDataFailure() {
  return { type: FETCH_OPPONENT_DATA_FAILURE, payload: {} }
}

export function fetchOpponentData() {
  return { type: FETCH_OPPONENT_DATA, payload: {} }
}
