import React, { Component } from "react";
import {
  Button,
  Container,
  Header,
  Title,
  Body,
  Left,
  Content,
  Right,
  Text
} from "native-base";
import { compose } from 'redux';
import { connect } from 'react-redux';
import { isLoaded, isEmpty, firebaseConnect, withFirestore } from 'react-redux-firebase';
import { withNavigation, HeaderBackButton} from 'react-navigation';
import Icon from '../utils/Icon';
import PropTypes from 'prop-types';


export class AppHeaderLeftInternal extends Component {
  render() {
    return (
          <Button
            transparent
            onPress={() => this.props.navigation.navigate('DrawerToggle') }
          >
            <Icon name="menu" size={25} style={{color: 'white'}}/>
          </Button>
    );
  }
}

export const AppHeaderLeft = withNavigation(AppHeaderLeftInternal);

const enhance = compose(
  withNavigation
  );

export class AppHeaderRightInternal extends Component {
  render() {
    return (
          <Button
            transparent
            onPress={() => this.props.navigation.navigate('Messages') }
          >
            <Icon name="email" size={25} style={{color: 'white'}}/>
          </Button>
    );
  }
}


export const AppHeaderRight = enhance(AppHeaderRightInternal);

export class ModalHeaderInternal extends Component {
  render() {
    const { title, icon, iconRight, onRightPress } = this.props;

    return (
      <Header style={{backgroundColor: "#3F51B5" }}>
        <Left>
          <Button transparent onPress={() => this.props.navigation.goBack() }>
            <Icon name={icon} size={20} style={{color: 'white'}} />
          </Button>
        </Left>
        <Body>
          <Title>{title}</Title>
        </Body>
        <Right>{iconRight ? <Icon name={iconRight} size={20} style={{color: 'white'}} onPress={onRightPress}/> : null}</Right>
      </Header>);
  }
}
const propTypes = {
    title:  PropTypes.string,
    icon: PropTypes.string,
    iconright: PropTypes.string,
    onRightPress: PropTypes.func
};
const defaultProps = {
    title: 'Empty',
    icon: 'arrow-left',
    iconright: null,
    onRightPress: null
};
ModalHeaderInternal.propTypes = propTypes;
ModalHeaderInternal.defaultProps = defaultProps;


export const ModalHeader = withNavigation(ModalHeaderInternal);
