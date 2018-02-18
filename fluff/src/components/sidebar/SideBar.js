import React, { Component } from "react";
import { Image } from "react-native";
import I18n from '../../../i18n/I18n';
import {
  Content,
  Text,
  List,
  ListItem,
  Container,
  Left,
  Right,
  Badge
} from "native-base";
import styles from "./style";
import { connect } from 'react-redux';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { isLoaded, isEmpty, firebaseConnect, withFirebase } from 'react-redux-firebase';
import Drawer from './drawer/Drawer';
import DrawerHeader from './drawer/DrawerHeader';
import DrawerSection from './drawer/DrawerSection';
import DrawerHeaderAccount from './drawer/DrawerHeaderAccount';


const drawerCover = require("../../../assets/drawer-cover.png");
const mainItems = [
  {
    value: I18n.t('profile'),
    route: "Profile",
    icon: "account-circle",
    key: '1'
  },
  {
    value: I18n.t('games'),
    route: "Games",
    icon: "calendar",
    key: '2'
  },
  {
    value: I18n.t('opponents'),
    route: "OpponentList",
    icon: "gamepad",
    key: '3'
  },
];

const otherItems = [
  {
    value: I18n.t('logout'),
    route: "Logout",
    icon: "logout",
    key: '4'
  },
  {
    value: I18n.t('settings'),
    route: "Settings",
    icon: "settings",
    key: '5'
  },
  {
    value: I18n.t('help'),
    route: "Help",
    icon: "help",
    key: '6'
  },
  {
    value: I18n.t('sendfeedback'),
    route: "SendFeedback",
    icon: "email",
    key: '7'
  }
];

class SideBar extends Component {
  constructor(props) {
    super(props);
    this.state = {
      shadowOffsetWidth: 1,
      shadowRadius: 4
    };
  }

  render() {

    if (isEmpty(this.props.auth)) {
       MyIcon = <Icon name="account-circle" style={styles.drawerImage} />;
    } else {
      if (this.props.auth.photoURL) {
        MyIcon = <Thumbnail source={this.props.auth.photoURL}  style={styles.drawerImage} />
      } else {
        MyIcon = <Icon name="account-circle" style={styles.drawerImage} />;
      }
    }

    return (
      <Container>
        <Drawer>
          <DrawerHeader>
            <DrawerHeaderAccount
              avatar={MyIcon}
              footer={{
                dense: true,
                centerElement: {
                  primaryText: this.props.auth.displayName,
                  secondaryText: this.props.auth.email
                },
                rightElement: 'arrow-drop-down'
              }}
            />
          </DrawerHeader>
          <DrawerSection
            divider
            items={mainItems}
          />
          <DrawerSection
            title="fluff"
            items={otherItems}
          />
        </Drawer>
      </Container>
    );
  }
}

export default connect(({ firebase: { auth, profile } }) => ({
  auth,
  profile
}))(SideBar);
