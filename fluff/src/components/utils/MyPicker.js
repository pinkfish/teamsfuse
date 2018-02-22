import React, { Component } from 'react';
import { View, Modal } from 'react-native';
import { Label, ListItem, Text, List, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';

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
    const { options, title, input, ...inputProps } = this.props;

    ret =
        <ListItem {...inputProps} icon onPress={this.openModal}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title} onLeftPress={this.closeModal}/>
              <Content>
                <List>
                  {options.map((item) => this.renderItem(item))}
                </List>
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
