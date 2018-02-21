/*
 * Action types.
 */
export const FETCH_GAME_DATA_SUCCESS = "FETCH_GAME_DATA_SUCCESS";
export const FETCH_GAME_DATA_FAILURE = "FETCH_GAME_DATA_FAILURE";
export const FETCH_GAME_DATA = "FETCH_GAME_DATA";
export const FETCH_GAME_DATA_CANCEL = "FETCH_GAME_DATA_CANCEL";
export const FETCH_GAME_DATA_ADD = "FETCH_GAME_DATA_ADD";
export const FETCH_GAME_DATA_DELETE = "FETCH_GAME_DATA_DELETE";
export const FETCH_GAME_DATA_UPDATE = "FETCH_GAME_DATA_UPDATE";


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

export function fetchGameDataAdd(game) {
  return { type: FETCH_GAME_DATA_ADD, game }
}

export function fetchGameDataDelete(game) {
  return { type: FETCH_GAME_DATA_DELETE, game }
}

export function fetchGameDataUpdate(game) {
  return { type: FETCH_GAME_DATA_UPDATE, game }
}
