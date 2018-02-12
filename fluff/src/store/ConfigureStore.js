// Redux Store Configuration
import { createStore } from 'redux';
import thunk from 'redux-thunk';
import AppReducer from '../reducers/AppReducer';

const configureStore = (initialState: Object) => {
  return createStore(AppReducer, initialState);
};

export default configureStore;
