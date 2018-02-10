/ full code here --> https://github.com/bizz84/redux-navigation-color-picker
import { combineReducers } from 'redux';
import UserReducer from './UserReducer';

const AppReducer = combineReducers({
  nav: UserReducer,
});

export default AppReducer;
