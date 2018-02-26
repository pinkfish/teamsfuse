import React, { Component } from 'react';
import { View, Modal } from 'react-native';
import { Label, ListItem, Text, Item, List, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import styles from './styles';

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
    return <Item key={item.key} onPress={() => this.selectItem(item)} icon style={styles.item}>
            <Body>
               <Text>{item.title}</Text>
             </Body>
             {item.key == input.value && <Right><Icon name='mat-check'/></Right>}
          </Item>
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
    const { options, title, input, disabled, disableValid, meta, icon, ...inputProps } = this.props;

    if ((meta.submitFailed || !meta.pristine) && !disableValid) {
      if (meta.invalid) {
        inputProps.error = true
      } else {
        inputProps.success = true
      }
    }

    ret =
        <Item {...inputProps} icon onPress={disabled ? () => {}: this.openModal}
          style={styles.item} icon>
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
          {icon ? <Left style={styles.itemLeft} ><Icon name={icon} /></Left> : null}
          <Body style={styles.itemBody}>
            {input.value != '' && <Text>{this.showValue()}</Text>}
            {input.value == '' && <Text note>{title}</Text>}
          </Body>
          <Right style={styles.itemRight}>
            <Icon name='mat-chevron-right' />
          </Right>
        </Item>;
    console.log('ret', ret);

    return ret;
  }
}
