import React, { Component, View } from "react";
import {
  Container,
  Content,
} from "native-base";
import styles from "./styles";
import VerifyEmailForm from './VerifyEmailForm';
import I18n from '../../../i18n/I18n';


class VerifyEmail extends Component {
  render() {
    const { handleSubmit, submitting } = this.props

    return (
      <Container style={styles.container}>
        <VerifyEmailForm />
      </Container>
    );
  }
}

export default VerifyEmail;
