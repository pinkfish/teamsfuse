/*
 * Action types.
 */
export const FETCH_GAME_DATA_SUCCESS = "FETCH_GAME_DATA_SUCCESS";
export const FETCH_GAME_DATA_FAILURE = "FETCH_GAME_DATA_FAILURE";
export const FETCH_GAME_DATA = "FETCH_GAME_DATA";
export const FETCH_GAME_DATA_CANCEL = "FETCH_GAME_DATA_CANCEL";


/*
* Action creators.
*/
export function fetchGameDataSuccess(allPlayers) {
  return { type: FETCH_GAME_DATA_SUCCESS, payload: allPlayers }
}

export function fetchGameDataFailure() {
  return { type: FETCH_GAME_DATA_FAILURE, payload: {} }
}

export function fetchGameData() {
  return { type: FETCH_GAME_DATA, payload: {} }
}
