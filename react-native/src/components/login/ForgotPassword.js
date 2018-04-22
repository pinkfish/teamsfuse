import React, { Component, View } from "react";
import {
  Container,
  Content,
} from "native-base";
import styles from "./styles";
import ForgotPasswordForm from './ForgotPasswordForm';
import I18n from '../../../i18n/I18n';


class ForgotPassword extends Component {
  render() {
    const { handleSubmit, submitting } = this.props

    return (
      <Container>
        <ForgotPasswordForm />
      </Container>
    );
  }
}

export default ForgotPassword;
