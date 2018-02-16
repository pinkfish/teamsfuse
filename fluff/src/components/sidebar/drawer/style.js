const React = require("react-native");
import material from "../../../theme/variables/material";

const { Platform, Dimensions } = React;

const deviceHeight = Dimensions.get("window").height;
const deviceWidth = Dimensions.get("window").width;

export default {
  drawer: {
    container: {
      flex: 1,
      backgroundColor: "white",
    }
  },
  drawerHeader: {
     container: {
         position: 'absolute',
         top: 0,
         left: 0,
         right: 0,
     },
     contentContainer: {
         backgroundColor: material.grey500,
         height: 150,
     },
   },
   drawerHeaderAccount: {
       container: {
           flex: 1,
           paddingBottom: 8,
       },
       accountContainer: {
           flex: 1,
           paddingHorizontal: 16,
           marginBottom: 8,
       },
       topContainer: {
           flex: 1,
           justifyContent: 'center',
       },
       avatarsContainer: {
           flexDirection: 'row',
       },
       activeAvatarContainer: {
           flex: 1,
       },
       inactiveAvatarContainer: {
           paddingLeft: 8,
       },
   },
   drawerHeaderListItem: {
       backgroundColor: "transparent",
   },
   drawerSection: {
       container: {
           paddingVertical: 8,
       },
       item: {
           flex: 1,
           flexDirection: 'row',
           alignItems: 'center',
           height: 48,
           paddingLeft: 16,
       },
       subheader: {
           flex: 1,
       },
       icon: {
           position: 'absolute',
           top: 13,
       },
       value: {
           flex: 1,
           paddingLeft: 56,
           top: 2,
       },
       label: {
           paddingRight: 16,
           top: 2,
       },
   },
   drawerSectionActiveItem: {
       container: {
           backgroundColor: material.grey100,
       },
       leftElement: {
           color: material.brandPrimary,
       },
       primaryText: {
           fontWeight: '500',
           fontSize: material.fontSizeBase,
           color: material.brandPrimary,
       },
   },
};
