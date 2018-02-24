import React, { Component } from 'react';
import { Modal, View } from 'react-native';
import { Text, Content, Spinner } from 'native-base';
import Icon from './Icon';
import TimePickerInternal from './TimePickerInternal';
import styles from './styles';

export default function(props) {
  const { closeModal, visible } = props;
  return <Modal
     visible={visible}
     animationType={'slide'}
     onRequestClose={closeModal}
   >
     <View style={styles.modalContainer}>
       <View style={styles.innerContainer}>
         <Text>Saving</Text>
         <Spinner color="green" />
       </View>
     </View>
  </Modal>;
}
