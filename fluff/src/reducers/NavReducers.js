import AppNavigation from "../components/app/AppNavigator";

export const NavReducer = (state, action) => {
  const newState = AppNavigation.router.getStateForAction(action, state)
  return newState || state
}
