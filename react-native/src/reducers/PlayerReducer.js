import { SET_CURRENT_PLAYER } from "../actions/Players";

export const CurrentPlayerReducer = (state = { uid: 0 }, action) => {
  // console.log('GLOBALS.JS REDUCER, action:', action);

  if(action.type === SET_CURRENT_PLAYER) {
    console.log('players.js', action)
    return ({ ...state, currentPlayer: action.payload})
  }
  else {
    return ({ ...state })
  }
}
