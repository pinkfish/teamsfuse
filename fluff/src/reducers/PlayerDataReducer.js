import {
  FETCH_PLAYER_DATA,
  FETCH_PLAYER_DATA_CANCEL,
  FETCH_PLAYER_DATA_SUCCESS,
  FETCH_PLAYER_DATA_FAILURE
} from "../actions/Players";

export const PlayerDataReducer = (state = { uid: 0 }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);
  switch(action.type) {
  case FETCH_PLAYER_DATA:
    return {
      ...state,
      fetchStatus: `fetching for ${action.payload}... ${(new Date()).toLocaleString()}`,
      list: []
    };
  case FETCH_PLAYER_DATA_SUCCESS:
    console.log('Fetched all player data', action.payload)
    return {
      ...state,
      list: action.payload,
      fetchStatus: `Results from ${(new Date()).toLocaleString()}`
    };
  case FETCH_PLAYER_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`
    };
  default:
    return state;
  }
}
