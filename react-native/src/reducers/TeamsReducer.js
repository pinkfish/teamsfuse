import { SET_CURRENT_TEAM } from "../actions/Teams";

export const CurrentTeamReducer = (state = { uid: 0 }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);

  if(action.type === SET_CURRENT_TEAM) {
    console.log('teams.js', action.type)
    return ({ ...state, currentTeam: action.payload})
  }
  else {
    return ({ ...state })
  }
}
