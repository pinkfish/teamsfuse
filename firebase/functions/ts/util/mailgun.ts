import * as functions from 'firebase-functions';
import * as nodemailer from 'nodemailer';
import mailgunTransport from 'nodemailer-mailgun-transport';
import SMTPTransport from 'nodemailer/lib/smtp-transport';

// Configure options for mailgun.
export const mailgunOptions = {
    auth: {
        api_key: functions.config().mailgun.apikey,
        domain: functions.config().mailgun.domain,
    },
};

const innerTransport = mailgunTransport(mailgunOptions);
const transport = nodemailer.createTransport(innerTransport);

// This is a bit hacky, but it does allow this to be injected via a test.
export const mailTransport = { transport: (): nodemailer.Transporter => transport };

export async function sendMail(mailOptions: nodemailer.SendMailOptions): Promise<SMTPTransport.SentMessageInfo> {
    const emailClient = mailTransport.transport();
    const info = await emailClient.sendMail(mailOptions);
    console.log('Message sent: %s', info.messageId);
    // Preview only available when sending through an Ethereal account
    console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

    // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@blurdybloop.com>
    // Preview URL: https://ethereal.email/message/WaQKMgKddxQDoou...
    return info;
}
