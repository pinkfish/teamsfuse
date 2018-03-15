import React, { Component } from 'react';
import { View, Modal } from 'react-native';
<<<<<<< HEAD
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
=======
import { Label, Item, Text, List, Container, Content, Left, Body, Right } from 'native-base';
import { ModalHeader } from '../app/AppHeader';
import Icon from './Icon';
import styles from "./styles";
>>>>>>> 301cb850a5aa7aa1460467501138833d2388dd1d

const ITEM_LIST = [ 0, 5,  10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 240 ];

export default class MyDurationPicker extends Component {
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
<<<<<<< HEAD
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
=======
    return <Item key={'time' + item} onPress={() => this.selectItem(item)} icon style={styles.item}>
            <Left style={styles.itemLeft}></Left>
            <Body style={styles.itemBody}>
               <Text>{item}</Text>
             </Body>
             {item == input.value && <Right style={styles.itemRight}><Icon name='mat-check'/></Right>}
          </Item>
>>>>>>> 301cb850a5aa7aa1460467501138833d2388dd1d
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
<<<<<<< HEAD
    const { title, input, disabled, ...inputProps } = this.props;
=======
    const { options, title, input, disabled, icon, ...inputProps } = this.props;
>>>>>>> 301cb850a5aa7aa1460467501138833d2388dd1d

    ret =
        <Item {...inputProps} icon onPress={disabled ? () => {}: this.openModal} style={styles.item}>
          <Modal
              visible={this.state.modalVisible}
              animationType={'slide'}
              onRequestClose={() => this.closeModal()}
              >
            <Container>
              <ModalHeader title={title} onLeftPress={this.closeModal}/>
              <Content>
<<<<<<< HEAD
                <Grid>
                  <Col>
                    {HOURS.map((item) => this.renderItem(item))}
                  </Col>
                  <Col>
                    {MINUTES.map((item) => this.renderItem(item))}
                  </Col>
                </Grid>
=======
                <List>
                  {ITEM_LIST.forEach((value) => (this.renderItem(value)))}
                </List>
>>>>>>> 301cb850a5aa7aa1460467501138833d2388dd1d
              </Content>
            </Container>
          </Modal>
          <Left style={styles.itemLeft}>
            <Icon name="calendar-range" />
          </Left>
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
