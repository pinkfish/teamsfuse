/* eslint-disable import/no-unresolved, import/extensions */
import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { View, Image, StyleSheet, ViewPropTypes } from 'react-native';
import styles from "./style";

const propTypes = {
    image: PropTypes.shape({ type: PropTypes.oneOf([Image]) }),
    backgroundColor: PropTypes.string,
    children: PropTypes.node,
    style: PropTypes.shape({
        contentContainer: ViewPropTypes.style,
        container: ViewPropTypes.style,
    }),
};
const defaultProps = {
    image: null,
    backgroundColor: null,
    children: null,
    style: {},
};
const contextTypes = {
    uiTheme: PropTypes.object.isRequired,
};

class DrawerHeader extends PureComponent {
    render() {
        const { image, children } = this.props;


        const content = (
            <View style={styles.drawerHeader.contentContainer}>
                {children}
            </View>
        );

        if (image) {
            return (
                <View>
                    {React.cloneElement(image, { style: [{ height: 25 }] })}
                    <View style={styles.drawerHeader.container}>
                        {content}
                    </View>
                </View>
            );
        }

        return content;
    }
}

DrawerHeader.propTypes = propTypes;
DrawerHeader.defaultProps = defaultProps;

export default DrawerHeader;
