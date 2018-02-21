import {
  FETCH_PLAYER_DATA,
  FETCH_PLAYER_DATA_CANCEL,
  FETCH_PLAYER_DATA_SUCCESS,
  FETCH_PLAYER_DATA_FAILURE,
  FETCH_PLAYER_DATA_ADD,
  FETCH_PLAYER_DATA_DELETE,
  FETCH_PLAYER_DATA_UPDATE
} from "../actions/Players";

export const PlayerDataReducer = (state = { loaded: 0 }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);
  switch(action.type) {
  case FETCH_PLAYER_DATA:
    // Don't overwrite the list while lodingh, just track the loading/loaded state.
    return {
      ...state,
      fetchStatus: `fetching for ${action.payload}... ${(new Date()).toLocaleString()}`,
      loading: true
    };
  case FETCH_PLAYER_DATA_SUCCESS:
    console.log('Fetched all player data', action.payload)
    return {
      ...state,
      list: action.payload,
      fetchStatus: `Results from ${(new Date()).toLocaleString()}`,
      loading: false,
      loaded: Date.now()
    };
  case FETCH_PLAYER_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`,
      loading: false
    };
  case FETCH_PLAYER_DATA_ADD:
    newState = {
      ...state
    };
    newState.list.push(action.payload);
    newState.fetchStatus = `Player add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_PLAYER_DATA_DELETE:
    newState = {
      ...state
    };
    // find the item and erase it.
    newState.list = newState.list.filter(function(player) {
      return player.uid != action.payload.uid;
    });
    newState.fetchStatus = `Player delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_PLAYER_DATA_UPDATE:
    newState = {
      ...state
    };
    newState.list.forEach((player) => {
      if (player.uid == payload.uid) {
        // Merge the data into this element.
        player = {
          ...player,
          ...payload
        };
      }
    });
    return newState;
  default:
    return state;
  }
}
