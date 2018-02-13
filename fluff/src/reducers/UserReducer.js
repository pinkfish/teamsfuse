import {LOGIN} from '../actions/User.js';

const initialState = {
  loggedIn: false,
  name: 'Unknown',
  id: '0',
  email: ''
};

const UserReducer = (state = initialState, action) => {
  switch (action) {
    case LOGIN:
      return { ...state, loggedIn: action.payload.loggedIn };
    default:
      return state;
  }
};

export default UserReducer;
