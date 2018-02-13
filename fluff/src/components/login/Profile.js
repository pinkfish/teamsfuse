import React, { Component } from "react";
import { Content, Card, CardItem, Text, Body, Container } from "native-base";
import { ModalHeader } from "../app/AppHeader";
import {
  Button,
  Header,
  Title,
  Icon,
  Left,
  Right,
} from "native-base";


export default class Profile extends Component {
  render() {
    return (
      <Container>
        <ModalHeader />
        <Content padder>
          <Card>
            <CardItem>
              <Body>
                <Text>David Bennett</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>Rowen Bennett</Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Nice image
                </Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Address
                </Text>
              </Body>
            </CardItem>
            <CardItem>
              <Body>
                <Text>
                  Phone
                </Text>
              </Body>
            </CardItem>
          </Card>
        </Content>
      </Container>

    );
  }
}
