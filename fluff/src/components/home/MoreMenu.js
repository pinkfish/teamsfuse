import React, { Component } from "react";
import {
  Menu,
  MenuOptions,
  MenuOption,
  MenuTrigger,
} from 'react-native-popup-menu';
import { Icon, Text } from "native-base";

export default class MoreMenu extends Component {
  render() {
    return (
      <Menu>
        <MenuTrigger>
          <Icon name="md-more" />
        </MenuTrigger>
        <MenuOptions>
          <MenuOption onSelect={() => alert(`Save`)} text='Something' />
          <MenuOption onSelect={() => alert(`Delete`)} >
            <Text style={{color: 'red'}}>SOmetbing else</Text>
          </MenuOption>
          <MenuOption onSelect={() => alert(`Not called`)} disabled={true} text='Disabled' />
        </MenuOptions>
      </Menu>);
  };
}
