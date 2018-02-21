import {
  FETCH_TEAM_DATA,
  FETCH_TEAM_DATA_CANCEL,
  FETCH_TEAM_DATA_SUCCESS,
  FETCH_TEAM_DATA_FAILURE,
  FETCH_TEAM_DATA_ADD,
  FETCH_TEAM_DATA_DELETE,
  FETCH_TEAM_DATA_UPDATE
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
  case FETCH_TEAM_DATA_ADD:
    newState = {
      ...state
    };
    newState.list.push(action.payload);
    newState.fetchStatus = `Team add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_TEAM_DATA_DELETE:
    newState = {
      ...state
    };
    // find the item and erase it.
    newState.list = newState.list.filter(function(team) {
      return team.uid != action.payload.uid;
    });
    newState.fetchStatus = `Team delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_TEAM_DATA_UPDATE:
    newState = {
      ...state
    };
    newState.list.forEach((team) => {
      if (team.uid == payload.uid) {
        // Merge the data into this element.
        team = {
          ...team,
          ...payload
        }
      }
    });
    return newState;
  default:
    return state;
  }
}
