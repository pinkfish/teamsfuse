/*
 * Action types.
 */
export const SET_CURRENT_TEAM = "SET_CURRENT_TEAM";

/*
 * Action creators.
 */
 export function setTeam(team) {
   return { type: SET_CURRENT_TEAM, team }
 }
