import React, { Component } from 'react';
import { View, Modal } from 'react-native';
import { Label, ListItem, Text, List, Container, Content, Left, Body, Right, Grid, Col } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';

const HOURS =  [
  { title: "0", value: 0 },
  { title: "1", value: 1 },
  { title: "2", value: 1 },
  { title: "3", value: 1 },
  { title: "4", value: 1 },
  { title: "5", value: 1 },
  { title: "6", value: 1 },
  { title: "7", value: 1 },
];

const MINUTES =  [
  { title: "0", value: 0 },
  { title: "5", value: 1 },
  { title: "10", value: 1 },
  { title: "20", value: 1 },
  { title: "15", value: 1 },
  { title: "30", value: 1 },
  { title: "40", value: 1 },
  { title: "45", value: 1 },
  { title: "50", value: 1 },
];

export default class MyPicker extends Component {
  constructor(props) {
    super(props)
    this.state = {
      modalVisible: false,
    };
  }


  openModal = () => {
    this.setState({modalVisible:true});
  }

  closeModal = () => {
    this.setState({modalVisible:false});
  }

  renderItem = (item) => {
    const { input } = this.props;
    return <ListItem key={item.key} onPress={() => this.selectItem(item)} icon>
            <Body>
               <Text>{item.title}</Text>
             </Body>
             {item.key == input.value && <Right><Icon name='mat-check'/></Right>}
          </ListItem>
  }

  selectItem = (item) => {
    this.props.input.onChange(item.key);
    this.closeModal();
    if (item.onPress) {
      item.onPress(item);
    }
  }

  showValue = () => {
    const { options, input } = this.props;

    for (opt in options) {
      opt = options[opt];
      if (opt.key == this.props.input.value) {
        return opt.title;
      }
    }
    return 'Unknown';
  }

  render() {
    const { title, input, disabled, ...inputProps } = this.props;

    ret =
        <ListItem {...inputProps} icon onPress={disabled ? () => {}: this.openModal}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title} onLeftPress={this.closeModal}/>
              <Content>
                <Grid>
                  <Col>
                    {HOURS.map((item) => this.renderItem(item))}
                  </Col>
                  <Col>
                    {MINUTES.map((item) => this.renderItem(item))}
                  </Col>
                </Grid>
              </Content>
            </Container>
          </Modal>
          <Body>
            {input.value != '' && <Text>{this.showValue()}</Text>}
            {input.value == '' && <Text note>{title}</Text>}
          </Body>
          <Right>
            <Icon name='mat-chevron-right' />
          </Right>
        </ListItem>;
    console.log('ret', ret);

    return ret;
  }
}
