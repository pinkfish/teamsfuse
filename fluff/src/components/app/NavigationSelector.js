import React, { Component } from "react";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, withFirestore } from 'react-redux-firebase';
import SignedOutNavigator from "./SignedOutNavigator";
import ModalNavigator from "./ModalNavigator";
import { setTeam } from "../../actions/Teams";
import { fetchPlayerData } from "../../actions/Players";

class NavigationSelector extends Component {
  componentWillMount = () => {
    // Refresh the login in here.
    this.props.firebase.reloadAuth()
        .then((cred) => {
          console.log('reloaded auth');
          // Load the subprofile into the store too.
          this.props.dispatch(fetchPlayerData());
        })
        .catch((error) => {
          console.log('Error reloading auth', error)
        })
  }

  render() {
    const { dispatch, currentTeam } = this.props;

    if (!this.props.auth || !this.props.auth.uid) {
      return <SignedOutNavigator />;
    }

    return <ModalNavigator />;
  }
}

const mapStateToProps = state => {
  return {
    currentTeam: state.currentTeam
  }
}

const enhance = compose(
  connect(
  // Map redux state to component props
  ({ firebase: { auth, profile } }) => ({
    auth,
    profile
  })),
  connect(mapStateToProps),
  withFirestore
  );

export default enhance(NavigationSelector);
