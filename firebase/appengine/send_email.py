import webapp2
import time
import json
from google.appengine.api import users

class SendEmailHandler(webapp2.RequestHandler):
    """Serves the email address sign up form."""

    def post(self):
        user = users.get_current_user()
        if user:
            # Send some email.
            user_address = self.request.get('email_address')
            subject = self.request.get('subject')
            body = self.request.get('body')
            from_id = self.request.get('userid')

            if not mail.is_email_valid(user_address):
                self.response.headers['Content-Type'] = 'application/json'
                self.response.write('Invalid email address')
            else:
                confirmation_url = create_new_user_confirmation(user_address)
                sender_address = (
                    'Example.com Support <{}@teamfuse.appspotmail.com>'.format(
                            from_id))
                subject = 'stuff'
                body = """Thanks for stuff""".format(confirmation_url)
                mail.send_mail(sender_address, user_address, subject, body)
                self.response.headers['Content-Type'] = 'application/json'
                self.response.write('Sent email')
        else:
            greeting = 'Access denied'
            self.response.headers['Content-Type'] = 'application/json'
            self.response.write(greeting)
