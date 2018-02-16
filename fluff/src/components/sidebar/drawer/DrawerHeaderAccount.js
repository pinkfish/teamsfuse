/* eslint-disable import/no-unresolved, import/extensions */
import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { View, TouchableWithoutFeedback, ViewPropTypes } from 'react-native';
/* eslint-enable import/no-unresolved, import/extensions */
import { Container, ListItem } from "native-base";
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

        const props = {
            ...footer,
            style: styles.drawerHeaderListItem,
        };

        return <ListItem {...props} />;
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
    renderAccounts = () => {
        const { accounts } = this.props;

        if (!accounts) {
            return null;
        }

        // TODO: slice of accounts
        // add more soficticated slice when there will be lots of accounts
        return accounts.slice(0, 3).map(this.renderAccount);
    }
    render() {
        const { avatar } = this.props;

        return (
            <Container style={styles.drawerHeaderAccount.container}>
                <View style={styles.drawerHeaderAccount.accountContainer}>
                    <View style={styles.drawerHeaderAccount.topContainer}>
                        <View style={styles.drawerHeaderAccount.avatarsContainer}>
                            <View style={styles.drawerHeaderAccount.activeAvatarContainer}>
                                {React.cloneElement(avatar, { size: 56 })}
                            </View>
                        </View>
                    </View>
                </View>
                {this.renderFooter()}

            </Container>
        );
    }
}

DrawerHeaderAcount.propTypes = propTypes;
DrawerHeaderAcount.defaultProps = defaultProps;

export default DrawerHeaderAcount;
