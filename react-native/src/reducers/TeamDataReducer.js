import {
  FETCH_TEAM_DATA,
  FETCH_TEAM_DATA_CANCEL,
  FETCH_TEAM_DATA_SUCCESS,
  FETCH_TEAM_DATA_FAILURE,
  FETCH_TEAM_DATA_ADD,
  FETCH_TEAM_DATA_DELETE,
  FETCH_TEAM_DATA_UPDATE
} from "../actions/Teams";
import {
  FETCH_OPPONENT_DATA,
  FETCH_OPPONENT_DATA_CANCEL,
  FETCH_OPPONENT_DATA_SUCCESS,
  FETCH_OPPONENT_DATA_FAILURE
} from "../actions/Opponents";

export const TeamDataReducer = (state = { loaded: false, loadedOpponents: false, loadedLocations: false }, action) => {
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
    // If we already have a list, then disable all the onsnapshot stuff.
    if (state.list && state.list.length > 0) {
      state.list.forEach((team) => {
        if (team.snapshotListen) {
          team.snapshotListen();
          team.snapshotListen = null;
        }
        if (team.snapshotListenOpponent) {
          team.snapshotListenOpponent();
          team.snapshotListenOpponent = null;
        }
      });
    }
    for (key in state.list) {
      if (action.payload.hasOwnProperty(key)) {
        if (state.list.hasOwnProperty(key)) {
          if (!action.payload[key].opponents) {
            action.payload[key].opponents = state.list[key].opponents;
          }
        }
        if (!action.payload.opponents) {
          action.payload.opponents = {};
        }
      }
    }
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
  case FETCH_TEAM_DATA_UPDATE:
    newState = {
      ...state
    };
    found = false;
    if (!newState.list) {
      console.error("List doesn't exist for team", newState);
      return newState;
    }
    team = action.payload;
    if (newState.list.hasOwnProperty(team.uid)) {
      newState.list[team.uid] = {
        ...newState.list[team.uid],
        ...action.payload
      };
    } else {
      newState.list[team.uid] = action.payload;
    }
    newState.fetchStatus = `Team add snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_TEAM_DATA_DELETE:
    newState = {
      ...state
    };
    // find the item and erase it.
    delete newState.list[team.uid];
    newState.fetchStatus = `Team delete snapshot ${(new Date()).toLocaleString()}`;
    return newState;
  case FETCH_OPPONENT_DATA:
    // Don't overwrite the list while lodingh, just track the loading/loaded state.
    return {
      ...state,
      fetchStatus: `fetching opponents for ${action.payload}... ${(new Date()).toLocaleString()}`,
      loadingOpponents: true
    };
  case FETCH_OPPONENT_DATA_SUCCESS:
    // If we already have a list, then disable all the onsnapshot stuff.
    // Update the team.
    newState = {
      ...state
    };
    team = action.team;
    opponentList = action.payload;
    console.log('opp', team, opponentList);
    newState.list[team.uid].opponents = opponentList;
    return {
      ...newState,
      fetchStatus: `Results oppnents from ${(new Date()).toLocaleString()}`,
      loadingOpponents: false,
      loadedOpponents: Date.now()
    };
  case FETCH_OPPONENT_DATA_FAILURE:
    return {
      ...state,
      fetchStatus: `errored: ${action.payload}`,
      loadingOpponents: false
    };
  default:
    return state;
  }
}
