/*
 * Action types.
 */
export const SET_CURRENT_PLAYER = "SET_CURRENT_PLAYER";
export const FETCH_PLAYER_DATA_SUCCESS = "FETCH_PLAYER_DATA_SUCCESS";
export const FETCH_PLAYER_DATA_FAILURE = "FETCH_PLAYER_DATA_FAILURE";
export const FETCH_PLAYER_DATA = "FETCH_PLAYER_DATA";
export const FETCH_PLAYER_DATA_CANCEL = "FETCH_PLAYER_DATA_CANCEL";

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
