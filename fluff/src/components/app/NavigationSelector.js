import React, { Component } from "react";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, withFirestore } from 'react-redux-firebase';
import { SignedOutNavigator, VerifyEmailNavigator } from "./SignedOutNavigator";
import ModalNavigator from "./ModalNavigator";
import { setTeam } from "../../actions/Teams";
import { fetchPlayerData } from "../../actions/Players";

class NavigationSelector extends Component {

  componentWillMount = () => {
    const { dispatch } = this.props;
    if (this.props.auth && this.props.auth.uid && this.props.auth.emailVerified) {
      // Request the players.
      dispatch(fetchPlayerData());
    } else if (this.props.auth.uid) {
      this.props.firebase.reloadAuth();
    }
  }

  render() {
    const { dispatch, currentTeam } = this.props;

    if (!this.props.auth || !this.props.auth.uid) {
      return <SignedOutNavigator />;
    }

    console.log('verified', this.props.firebase);
    if (!this.props.auth.emailVerified) {
      return <VerifyEmailNavigator />;
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
