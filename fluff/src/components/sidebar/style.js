const React = require("react-native");
const { Platform, Dimensions } = React;

const deviceHeight = Dimensions.get("window").height;
const deviceWidth = Dimensions.get("window").width;

export default {
  drawerCover: {
    alignSelf: "stretch",
    height: deviceHeight / 3.5,
    width: null,
    position: "relative",
    marginBottom: 10
  },
  drawerImage: {
    position: "absolute",
    left: Platform.OS === "android" ? 20 : 20,
    top: Platform.OS === "android" ? deviceHeight / 13 : deviceHeight / 12,
    width: 75,
    height: 75,
    color: "white"
  },
  drawerText: {
    fontSize: Platform.OS === "ios" ? 13 : 11,
    fontWeight: "400",
    textAlign: "center",
    color: "white",
    marginTop: Platform.OS === "android" ? -3 : undefined,
    position: "absolute",
    left: Platform.OS === "android" ? 20 + 75 : 20 + 75,
    top: Platform.OS === "android" ? deviceHeight / 13 + 40: deviceHeight / 12 + 40,
    width: 135,
    height: 75,
  },
  text: {
    fontWeight: Platform.OS === "ios" ? "500" : "400",
    fontSize: 16,
    marginLeft: 20
  },
  badgeText: {
    fontSize: Platform.OS === "ios" ? 13 : 11,
    fontWeight: "400",
    textAlign: "center",
    marginTop: Platform.OS === "android" ? -3 : undefined
  }
};
