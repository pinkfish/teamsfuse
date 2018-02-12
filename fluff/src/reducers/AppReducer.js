import { combineReducers } from 'redux';
import UserReducer from './UserReducer';

const AppReducer = combineReducers({
  nav: UserReducer,
});

export default AppReducer;
