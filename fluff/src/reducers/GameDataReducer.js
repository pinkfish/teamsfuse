import {
  FETCH_GAME_DATA,
  FETCH_GAME_DATA_CANCEL,
  FETCH_GAME_DATA_SUCCESS,
  FETCH_GAME_DATA_FAILURE,
  FETCH_GAME_DATA_ADD,
  FETCH_GAME_DATA_DELETE,
  FETCH_GAME_DATA_UPDATE
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
    console.log('Fetched all game data', action.payload)
    // If we already have a list, then disable all the onsnapshot stuff.
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
  case FETCH_GAME_DATA_ADD:
    newState = {
      ...state
    };
    found = false;
    newState.list.forEach((player) => {
      if (player.uid == action.payload.uid) {
        // Merge the data into this element.
        player = {
          ...player,
          ...payload
        };
        found = true;
      }
    });
    if (!found) {
      newState.list.push(action.payload);
    }
    newState.fetchStatus = `Player add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_GAME_DATA_DELETE:
    newState = {
      ...state
    };
    // find the item and erase it.
    newState.list = newState.list.filter(function(player) {
      return player.uid != action.payload.uid;
    });
    newState.fetchStatus = `Player delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_GAME_DATA_UPDATE:
    newState = {
      ...state
    };
    newState.list.forEach((player) => {
      if (player.uid == action.payload.uid) {
        // Merge the data into this element.
        player = {
          ...player,
          ...action.payload
        };
      }
    });
    return newState;
  default:
    return state;
  }
}
