import React, { Component } from "react";
import { TabNavigator, TabBarTop } from "react-navigation";
import I18n from '../../../i18n/I18n';
import {
  Button,
  Container,
  Footer,
  FooterTab,
  Header,
  Title,
  Tab,
  HeaderTab,
  Tabs,
  ScrollableTab,
  StatusBar,
  Body,
  Icon,
  Left,
  List,
  ListItem,
  Content,
  Right,
  Text
} from "native-base";
import Feather from 'react-native-vector-icons/Feather';
import styles from "./styles";
import Messages from "../messages/Messages";
import Schedule from "../schedule/Schedule";
import Stream from "../stream/Stream";

export default TabNavigator(
  {
    Stream: { screen: Stream },
    Schedule: { screen: Schedule },
    Messages: { screen: Messages },
  },
  {
    navigationOptions: ({ navigation }) => ({
      tabBarIcon: ({ focused, tintColor }) => {
        const { routeName } = navigation.state;
        let iconName;
        if (routeName === 'Schedule') {
          iconName = `ios-calendar${focused ? '' : '-outline'}`;
        } else if (routeName === 'Stream') {
          iconName = `ios-home${focused ? '' : '-outline'}`;
        } else if (routeName === 'Messages') {
          iconName = `ios-mail${focused ? '' : '-outline'}`;
        }

        // You can return any component that you like here! We usually use an
        // icon component from react-native-vector-icons
        return <Ionicons name={iconName} size={25} color={tintColor} />;
      },
    }),
    tabBarOptions: {
      activeTintColor: 'black',
      inactiveTintColor: 'gray',
    },
    tabBarPosition: 'top',
    animationEnabled: false,
    swipeEnabled: false,
    tabBarComponent: props => {
      return (
        <Container>
          <Footer>
          <FooterTab>
            <Button
              vertical
              active={props.navigationState.index === 0}
              onPress={() => props.navigation.navigate("Stream")}
            >
              <Icon name="ios-home" />
              <Text>{I18n.t('stream')}</Text>
            </Button>
            <Button
              vertical
              active={props.navigationState.index === 1}
              onPress={() => props.navigation.navigate("Schedule")}
            >
              <Icon name="ios-calendar" />
              <Text>{I18n.t('schedule')}</Text>
            </Button>
            <Button
              vertical
              active={props.navigationState.index === 2}
              onPress={() => props.navigation.navigate("Messages")}
            >
              <Icon name="ios-mail" />
              <Text>{I18n.t('messages')}</Text>
            </Button>
          </FooterTab>
        </Footer>
      </Container>
      );
    }
  }
);
