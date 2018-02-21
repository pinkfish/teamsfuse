import {
  FETCH_GAME_DATA,
  FETCH_GAME_DATA_CANCEL,
  FETCH_GAME_DATA_SUCCESS,
  FETCH_GAME_DATA_FAILURE
} from "../actions/Games";

export const GameDataReducer = (state = { loaded: 0 }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);
  switch(action.type) {
  case FETCH_GAME_DATA:
    // Don't overwrite the list while lodingh, just track the loading/loaded state.
    return {
      ...state,
      fetchStatus: `fetching for ${action.payload}... ${(new Date()).toLocaleString()}`,
      loading: true
    };
  case FETCH_GAME_DATA_SUCCESS:
    console.log('Fetched all player data', action.payload)
    return {
      ...state,
      list: action.payload,
      fetchStatus: `Results from ${(new Date()).toLocaleString()}`,
      loading: false,
      loaded: Date.now()
    };
  case FETCH_GAME_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`,
      loading: false
    };
  default:
    return state;
  }
}
