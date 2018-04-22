import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import { Content, Container, Card, CardItem, Text, Body, Header, Left, Right, Title, Button, Icon } from "native-base";

export default class Settings extends Component {
  render() {
    return (
      <Container>
        <ModalHeader />
        <Content padder>
          <Card>
            <CardItem>
              <Body>
                <Text>Fluff is open source and free.</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>Platform specific codebase for components</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Any native third-party libraries can be included along with
                  NativeBase.
                </Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Single file to theme your app and NativeBase components.
                </Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Gives an ease to include different font types in your app.
                </Text>
              </Body>
            </CardItem>
          </Card>
        </Content>
      </Container>
    );
  }
}
