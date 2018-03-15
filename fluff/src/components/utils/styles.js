import variables from "../../theme/variables/platform";

export default {
  item: {
    height: variables.inputHeightBase
  },
  itemBody: {
    alignItems: 'flex-start',
    flexDirection: 'row',
    flex: 1
  },
  itemLeft: {
    width: 25,
    flex: 0
  },
  itemRight: {
    width: 25,
    flex: 0
  },
  itemRightSwitch: {
    width: 50,
    flex: 0
  },
  roundButton: {
    height: variables.btnTextSizeLarge * 1.5,
    width: variables.btnTextSizeLarge * 1.5,
    marginRight: 8,
    marginTop: 8,
    justifyContent: 'center',
    backgroundColor: variables.listBtnUnderlayColor
  },
  roundButtonSelected: {
    backgroundColor: variables.btnPrimaryBg
  },
  roundButtonLabelSelected: {
    color: 'white',
  },
  iconstart: {
    fontSize: 20,
    color: 'black'
  },
  iconend: {
    fontSize: 15,
    color: 'black'
  }
};
