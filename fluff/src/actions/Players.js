/*
 * Action types.
 */
export const SET_CURRENT_PLAYER = "SET_CURRENT_PLAYER";
export const FETCH_PLAYER_DATA_SUCCESS = "FETCH_PLAYER_DATA_SUCCESS";
export const FETCH_PLAYER_DATA_FAILURE = "FETCH_PLAYER_DATA_FAILURE";
export const FETCH_PLAYER_DATA = "FETCH_PLAYER_DATA";
export const FETCH_PLAYER_DATA_CANCEL = "FETCH_PLAYER_DATA_CANCEL";
export const FETCH_PLAYER_DATA_ADD = "FETCH_PLAYER_DATA_ADD";
export const FETCH_PLAYER_DATA_DELETE = "FETCH_PLAYER_DATA_DELETE";
export const FETCH_PLAYER_DATA_UPDATE = "FETCH_PLAYER_DATA_UPDATE";

/*
 * Action creators.
 */
export function setPlayer(player) {
 return { type: SET_CURRENT_PLAYER, payload: player }
}

export function fetchPlayerDataSuccess(allPlayers) {
 return { type: FETCH_PLAYER_DATA_SUCCESS, payload: allPlayers }
}

export function fetchPlayerDataFailure() {
 return { type: FETCH_PLAYER_DATA_FAILURE, payload: {} }
}

export function fetchPlayerData() {
 return { type: FETCH_PLAYER_DATA, payload: {} }
}

export function fetchPlayerDataAdd(player) {
  return { type: FETCH_PLAYER_DATA_ADD, player }
}

export function fetchPlayerDataDelete(player) {
  return { type: FETCH_PLAYER_DATA_DELETE, player }
}

export function fetchPlayerDataUpdate(player) {
  return { type: FETCH_PLAYER_DATA_UPDATE, player }
}
