/*
 * Action types.
 */
export const LOGIN = "LOGIN";

/*
 * Action creators.
 */
 export function login(user) {
   return { type: LOGIN, user }
 }
