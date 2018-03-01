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
  switch(action.type) {
  case FETCH_GAME_DATA:
    // Don't overwrite the list while lodingh, just track the loading/loaded state.
    return {
      ...state,
      fetchStatus: `fetching for ${action.payload}... ${(new Date()).toLocaleString()}`,
      loading: true
    };
  case FETCH_GAME_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`,
      loading: false
    };
    case FETCH_GAME_DATA_SUCCESS:
      // If we already have a list, then disable all the onsnapshot stuff.
      newState = {
        ...state,
        fetchStatus: `Results from ${(new Date()).toLocaleString()}`,
        loading: false,
        loaded: Date.now()
      };
      if (!newState.list) {
        newState.list = {};
      }
      // Metge in the opponents.
      for (key in newState.list) {
        if (newState.list.hasOwnProperty(key)) {
          if (action.payload.hasOwnProperty(key)) {
            action.payload[key].opponents = newState.list[key].opponents;
          }
        }
      }
      newState.list = action.payload;
      return newState;
  case FETCH_GAME_DATA_UPDATE:
  case FETCH_GAME_DATA_ADD:
    newState = {
      ...state
    };
    found = false;
    game = action.payload;
    console.log(' bing', newState);
    if (newState.list) {
      newState.list = {};
    }
    if (newState.list.hasOwnProperty(game.uid)) {
      newState.list[game.uid] = {
        ...newState.list[game.uid],
        ...action.payload
      };
    } else {
      newState.list[game.uid] = action.payload;
    }
    newState.fetchStatus = `Player add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_GAME_DATA_DELETE:
    newState = {
      ...state
    };
    game = action.payload;
    // find the item and erase it.
    delete newState.list[game.uid];
    newState.fetchStatus = `Player delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  default:
    return state;
  }
}
