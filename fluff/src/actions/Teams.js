/*
 * Action types.
 */
export const SET_TEAM = "SET_TEAM";

/*
 * Action creators.
 */
 export function setTeam(team) {
   return { type: SET_TEAM, team }
 }
