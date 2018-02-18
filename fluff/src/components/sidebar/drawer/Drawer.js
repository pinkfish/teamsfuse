/* eslint-disable import/no-unresolved, import/extensions */
import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { ScrollView, ViewPropTypes } from 'react-native';
/* eslint-enable import/no-unresolved, import/extensions */
import { Container, List } from "native-base";
import styles from "./style";

const propTypes = {
    children: PropTypes.node.isRequired,
    style: PropTypes.shape({
        container: ViewPropTypes.style,
    }),
};
const defaultProps = {
    style: {},
};


class Drawer extends PureComponent {
    render() {
        const { children } = this.props;

        return (
            <Container style={styles.drawer.container}>
                <List icon>
                    {children}
                </List>
            </Container>
        );
    }
}

Drawer.propTypes = propTypes;
Drawer.defaultProps = defaultProps;

export default Drawer;
