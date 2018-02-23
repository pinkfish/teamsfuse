import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import { Content, Container, Text, Spinner } from "native-base";
import { Image, View } from "react-native";
import styles from './styles';

export default class Loading extends Component {
  render() {
    return (
      <Container>
        <Image source={require('../../../assets/launchscreen-bg.png')} style={styles.loadingimage}>
        </Image>
        <Text style={styles.loadingtext}>Loading...</Text>
        <Spinner color='green' />
      </Container>
    );
  }
}
