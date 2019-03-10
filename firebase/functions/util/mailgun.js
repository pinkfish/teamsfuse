"use strict";

const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const mailgunTransport = require("nodemailer-mailgun-transport");
// Configure options for mailgun.
const mailgunOptions = {
  auth: {
    api_key: functions.config().mailgun.apikey,
    domain: functions.config().mailgun.domain
  }
};

const mailTransport = mailgunTransport(mailgunOptions);

exports.sendMail = mailOptions => {
  var emailClient = nodemailer.createTransport(mailTransport);
  console.log(mailOptions);
  return emailClient.sendMail(mailOptions);
};
