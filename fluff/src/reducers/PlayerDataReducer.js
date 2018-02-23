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
    if (state.list && state.list.length > 0) {
      state.list.forEach((player) => {
        if (player.snapshotListen) {
          player.snapshotListen();
          player.snapshotListen = null;
        }
      });
    }
    return {
      ...state,
      list: action.payload.list,
      snapshotListen: action.payload.snapshotListen,
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
  case FETCH_PLAYER_DATA_UPDATE:
    console.log('player add', action);
    newState = {
      ...state
    };
    found = false;
    player = action.payload;
    if (newState.list.hasOwnProperty(player.uid)) {
      newState.list[player.uid] = {
        ...newState.list[player.uid],
        ...player
      };
    } else {
      newState.list[player.uid] = player;
    }
    newState.fetchStatus = `Player add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_PLAYER_DATA_DELETE:
    newState = {
      ...state
    };
    player = action.payload;
    // find the item and erase it.
    delete newState.list[player.uid];
    newState.fetchStatus = `Player delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  default:
    return state;
  }
}
