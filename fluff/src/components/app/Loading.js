import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import { Content, Container, Text, Spinner } from "native-base";

export default class Loading extends Component {
  render() {
    return (
      <Container>
        <Content padder>
          <Text>Loading...</Text>
          <Spinner color='green' />
        </Content>
      </Container>
    );
  }
}
