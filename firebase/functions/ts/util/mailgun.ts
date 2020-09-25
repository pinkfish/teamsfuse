import * as functions from 'firebase-functions';
import * as nodemailer from 'nodemailer';
import * as mailgunTransport from 'nodemailer-mailgun-transport';

// Configure options for mailgun.
export const mailgunOptions = {
    auth: {
        api_key: functions.config().mailgun.apikey,
        domain: functions.config().mailgun.domain,
    },
};

export const mailTransport = mailgunTransport(mailgunOptions);

export function sendMail(mailOptions: nodemailer.SendMailOptions) {
    const emailClient = nodemailer.createTransport(mailTransport);
    console.log(mailOptions);
    return emailClient.sendMail(mailOptions);
}
