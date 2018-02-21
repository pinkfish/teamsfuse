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
import { compose } from 'redux';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { isLoaded, isEmpty, firestoreConnect, withFirestore } from 'react-redux-firebase';
import Drawer from './drawer/Drawer';
import DrawerHeader from './drawer/DrawerHeader';
import DrawerSection from './drawer/DrawerSection';
import DrawerHeaderAccount from './drawer/DrawerHeaderAccount';
import { fetchPlayerData } from '../../actions/Players.js';
import { fetchTeamData } from '../../actions/Teams.js';


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

  componentWillMount = () => {
    const { teams, players, dispatch } = this.props;

    if (players.loaded == 0) {
      // Request the players.
      dispatch(fetchPlayerData());
    } else if (teams.loaded == 0) {
      dispatch(fetchTeamData());
    }
  }

  render() {
    const { teams, auth, players }  = this.props;

    if (isEmpty(this.props.auth)) {
       MyIcon = <Icon name="account-circle" style={styles.drawerImage} />;
    } else {
      if (auth.photoURL) {
        MyIcon = <Thumbnail source={auth.photoURL}  style={styles.drawerImage} />
      } else {
        MyIcon = <Icon name="account-circle" style={styles.drawerImage} />;
      }
    }

    myTeamArray = [];
    console.log('Teams', teams);
    console.log('Players', players);
    if (!teams.list|| teams.list.length == 0) {
    } else {
      for (team in teams) {
        myTeamArray.push( {
          value: team.name,
          route: "TeamView",
          icon: "mat-people",
          key: team.uid
        });
      }
    }
    myTeamArray.push({
      value: I18n.t('addteam'),
      route: "TeamEdit",
      icon: "mat-people",
      key: 'add'
    })

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
            title="Teams"
            items={myTeamArray}
          />
          <DrawerSection
            divider
            items={mainItems}
          />
          <DrawerSection
            items={otherItems}
          />
        </Drawer>
      </Container>
    );
  }
}

const enhance = compose(
    // Pass data from redux as a prop
    connect((state) => ({
      player: state.firebase.ordered.player,
      currentTeam: state.currentTeam,
      currentPlayer: state.currentPlayer,
      teams: state.teams,
      players: state.players
    })),
    connect(({ firebase: { auth, profile } }) => ({
      auth,
      profile,
    }))
  );

export default enhance(SideBar);
