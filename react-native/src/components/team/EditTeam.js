import React, { Component } from 'react'
import { connect } from 'react-redux';
import { Container } from 'native-base';
import EditTeamForm from './EditTeamForm';
import { ModalHeader } from "../app/AppHeader";
import I18n from '../../../i18n/I18n';

class EditTeam extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
         errorText: ''
    }
  }

  onPressItem = () => {
    // updater functions are preferred for transactional updates
    console.log(this.child);
    this.child.doSubmit();
  };

  render() {
    return (
      <Container>
        <ModalHeader title={I18n.t('profile')} iconRight="check" onRightPress={this.onPressItem}/>

        <EditTeamForm onMyFormRef={(ref) => (this.child = ref)} />
      </Container>
    );
  }
}

export default connect()(EditTeam);
