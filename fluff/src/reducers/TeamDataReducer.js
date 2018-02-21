import {
  FETCH_TEAM_DATA,
  FETCH_TEAM_DATA_CANCEL,
  FETCH_TEAM_DATA_SUCCESS,
  FETCH_TEAM_DATA_FAILURE
} from "../actions/Teams";

export const TeamDataReducer = (state = { loaded: false }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);
  switch(action.type) {
  case FETCH_TEAM_DATA:
    // Don't overwrite the list while lodingh, just track the loading/loaded state.
    return {
      ...state,
      fetchStatus: `fetching for ${action.payload}... ${(new Date()).toLocaleString()}`,
      loading: true
    };
  case FETCH_TEAM_DATA_SUCCESS:
    console.log('Fetched all player data', action.payload)
    return {
      ...state,
      list: action.payload,
      fetchStatus: `Results from ${(new Date()).toLocaleString()}`,
      loading: false,
      loaded: Date.now()
    };
  case FETCH_TEAM_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`,
      loading: false
    };
  default:
    return state;
  }
}
