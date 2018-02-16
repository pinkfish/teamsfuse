/* eslint-disable import/no-unresolved, import/extensions */
import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { View, Text, ViewPropTypes  } from 'react-native';
import { ListItem, Separator, Left, Body } from 'native-base';
/* eslint-enable import/no-unresolved, import/extensions */
import { withNavigation } from 'react-navigation';
import styles from "./style";
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';


const propTypes = {
    title: PropTypes.string,
    items: PropTypes.arrayOf(PropTypes.shape({
        icon: PropTypes.string,
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.element]).isRequired,
        label: PropTypes.string,
        route: PropTypes.string,
        onPress: PropTypes.func,
        onLongPress: PropTypes.func,
        active: PropTypes.bool,
        disabled: PropTypes.bool,
    })),
    divider: PropTypes.bool,
    style: PropTypes.shape({
        container: ViewPropTypes.style,
        item: ViewPropTypes.style,
        subheader: ViewPropTypes.style,
        icon: Text.propTypes.style,
        value: Text.propTypes.style,
        label: Text.propTypes.style,
    }),
    key: PropTypes.string,
};
const defaultProps = {
    title: null,
    items: [],
    divider: false,
    style: {},
    key: '',
};
const propInternalTypes = {
    item: PropTypes.shape({
        icon: PropTypes.string,
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.element]).isRequired,
        label: PropTypes.string,
        route: PropTypes.string,
        onPress: PropTypes.func,
        onLongPress: PropTypes.func,
        active: PropTypes.bool,
        disabled: PropTypes.bool,
    }),
    key: PropTypes.string,
};

class InternalListItem extends PureComponent {
  constructor(props, context) {
    super(props, context);
    this.onPressNavigate = this.onPressNavigate.bind(this);
  }

  onPressNavigate = (fluff, route) => {
    const { item } = this.props;

    console.log('item', item, fluff, route);
    if (item.route) {
      this.props.navigation.navigate(item.route);
    } else {
      item.onPress();
    }
  }

  render() {
    const { item, key } = this.props;
    return (
        <ListItem
            onPress={this.onPressNavigate}
            route={item.route}
            settingItem
        >
          <Left><Icon name={item.icon} size={20}/></Left>
          <Body><Text>{item.value}</Text></Body>
        </ListItem>
    );
  }
}

InternalListItem.propTypes = propInternalTypes;

const InternalWrappedItem = withNavigation(InternalListItem);


class DrawerSection extends PureComponent {

    renderTitle = () => {
        const { title } = this.props;

        return (<ListItem itemHeader>{title}</ListItem>);
    }
    onPressNavigate = (item, route) => {
      console.log('item', item, route);
      if (item.route) {
        this.navigation.navigate(item.route);
      } else {
        item.onPress();
      }
    }
    render() {
        const { items, divider } = this.props;

        return (
            <View key={this.props.key}>
                <View style={styles.drawerSection.container} >
                    {items && items.map((item) => {

                        return (
                            <InternalWrappedItem item={item} key={item.key} />
                        );
                    })}
                </View>
                {divider && <Separator noBottomBorder />}
            </View>
        );
    }
}

DrawerSection.propTypes = propTypes;
DrawerSection.defaultProps = defaultProps;

export default DrawerSection;
