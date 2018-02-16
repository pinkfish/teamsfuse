import { SET_TEAM } from "../actions/teams;

export const TeamReducer = (state = {}, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);

  if(action.type === SET_TEAM) {
    console.log('teams.js', action.type)
    return ({ ...state, team: action.payload})
  }
  else {
    return ({ ...state })
  }
}
