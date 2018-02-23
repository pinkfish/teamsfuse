import React, { Component } from 'react';
import { TimePickerAndroid } from 'react-native';

export default class TimePickerInternal extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
    };
  }

  showPicker = () => {
    TimePickerAndroid.open()
        .then((action, hour, minute) => {
          if (action == TimePickerAndroid.dismissedAction) {
            // Just close the dialog.
            this.props.onClose();
          } else {
            // Set the value then close it.

            this.props.onClose();
          }
        });

  }

  render() {
    const { value, onChange, enabled } = this.props;

    if (value instanceof Date) {
      displayValue = value;
    } else {
      displayValue = new Date();
    }
    if (enabled && !this.state.modalVisible) {
      this.setState({ modalVisible: true});
      // Open it up.
    }
    return <Text />;
  }
}
