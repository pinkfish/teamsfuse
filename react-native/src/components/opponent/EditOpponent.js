import React, { Component } from "react";
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';
import { connect } from 'react-redux';
import { Container } from "native-base";
import styles from './styles';
import EditOpponentForm from './EditOpponentForm';

const camera = require("../../../assets/camera.png");

class EditOpponent extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  onPressItem = () => {
    // updater functions are preferred for transactional updates
    this.child.doFluffSubmit();
  };

  render() {
    const { opponent, opponentId } = this.props

    return (
      <Container>
        <ModalHeader title={I18n.t('profile')} iconRight="check" onRightPress={this.onPressItem}/>

        <EditOpponentForm opponent={opponent} opponentId={opponentId} onMyFormRef={(ref) => (this.child = ref)} />
      </Container>
    );
  }
}

export default connect()(EditOpponent);
