/*
 * Action types.
 */
export const SET_CURRENT_TEAM = "SET_CURRENT_TEAM";
export const FETCH_TEAMS = "FETCH_TEAMS";
export const CANCEL_FETCH_TEAMS = "CANCEL_FETCH_TEAMS";

/*
 * Action creators.
 */
 export function setTeam(team) {
   return { type: SET_CURRENT_TEAM, team }
 }

 export function queryTeams(currentPlayer) {
   // If the uid is 0 then we query for all players.
   if (currentPlayer.uid == 0) {

   }
 }
