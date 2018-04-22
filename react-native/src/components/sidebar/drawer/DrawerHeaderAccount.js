/* eslint-disable import/no-unresolved, import/extensions */
import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { View, TouchableWithoutFeedback, ViewPropTypes } from 'react-native';
/* eslint-enable import/no-unresolved, import/extensions */
import { Container, ListItem, Body, Text } from "native-base";
import styles from "./style";

const propTypes = {
    avatar: PropTypes.element,
    accounts: PropTypes.arrayOf(PropTypes.shape({
        avatar: PropTypes.element,
        onPress: PropTypes.func,
    })),
    footer: PropTypes.shape(ListItem.propTypes),
    style: PropTypes.shape({
        container: ViewPropTypes.style,
        accountContainer: ViewPropTypes.style,
        topContainer: ViewPropTypes.style,
        avatarsContainer: ViewPropTypes.style,
        activeAvatarContainer: ViewPropTypes.style,
        inactiveAvatarContainer: ViewPropTypes.style,
    }),
};
const defaultProps = {
    avatar: null,
    accounts: null,
    footer: null,
};

class DrawerHeaderAcount extends PureComponent {
    componentWillMount = () => {
        // We need to change state if relevant props are changed
        this.setState({
            styles: {},
        });
    }
    renderFooter = () => {
        const { footer } = this.props;

        if (!footer) {
            return null;
        }
        const { centerElement, rightElement } = footer;

        const props = {
            ...footer,
            style: styles.drawerHeaderListItem,
        };
        if (centerElement) {
          return <Body style={styles.drawerHeaderListItem}>
            <Text>{centerElement.primaryText}</Text>
            <Text>{centerElement.secondaryText}</Text>
          </Body>
        }
        return <ListItem {...props} />
    }

    renderAccount = (account) => {
        const { styles } = this.state;

        // invariant(account.key, 'Please provide key prop to account object in accounts array.');

        return (
            <TouchableWithoutFeedback
                key={account.key}
                onPress={account.onPress}
            >
                <View style={styles.drawerHeaderAccount.inactiveAvatarContainer}>
                    {account.avatar}
                </View>
            </TouchableWithoutFeedback>
        );
    }
    render() {
        const { avatar } = this.props;

        return (
            <Container style={styles.drawerHeaderAccount.container}>
                {React.cloneElement(avatar, { size: 56 })}
                <Body style={{ flex: 1 }}>
                  {this.renderFooter()}
                </Body>

            </Container>
        );
    }
}

DrawerHeaderAcount.propTypes = propTypes;
DrawerHeaderAcount.defaultProps = defaultProps;

export default DrawerHeaderAcount;
