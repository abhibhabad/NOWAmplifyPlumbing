import json
import boto3
from botocore.exceptions import ClientError

# Define the support email address
SUPPORT_EMAIL = 'support@nowmobileordering.com'

# Initialize the SES client
ses = boto3.client('ses')

def sendCustomerEmail(user_email):
    """Send an acknowledgment email to the customer."""
    try:
        response = ses.send_email(
            Source=SUPPORT_EMAIL,
            Destination={
                'ToAddresses': [user_email],
            },
            Message={
                'Subject': {
                    'Data': 'We Received Your Support Request',
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': f"Hello,\n\nWe have received your support request and will respond shortly.\n\nBest regards,\nNow Mobile Ordering Support",
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        print(f"Sent acknowledgment email to {user_email}")
        return response
    except ClientError as e:
        print(f"Error sending email to customer: {e.response['Error']['Message']}")
        return None

def sendSupportEmail(support_email, user_email, message_body):
    """Send the support request details to the support team."""
    try:
        response = ses.send_email(
            Source=support_email,
            Destination={
                'ToAddresses': ["support@nowmobileordering.com","abhilash.bhabad@gmail.com", "andrew@nowmobileordering.com", "jake@nowmobileordering.com"],
            },
            Message={
                'Subject': {
                    'Data': f"New Support Request from {user_email}",
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': (
                            f"New support request received.\n\n"
                            f"User Email: {user_email}\n"
                            f"Message: {message_body}\n\n"
                            "Please follow up with the user."
                        ),
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        print(f"Sent support request details to {support_email}")
        return response
    except ClientError as e:
        print(f"Error sending email to support: {e.response['Error']['Message']}")
        return None

def handler(event, context):
    print('received event:')
    print(event)

    body = event.get('body')
    if body:
        body = json.loads(body)
        user_email = body.get('userEmail')
        message_body = body.get('messageBody')

        print(f"Received support request from: {user_email}")

        # Send acknowledgment email to the customer
        sendCustomerEmail(user_email)

        # Send the support email with details of the support request
        sendSupportEmail(SUPPORT_EMAIL, user_email, message_body)

        return {
            'statusCode': 200,
            'body': json.dumps('Support request processed successfully.')
        }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Bad request: Missing user email or message body.')
        }

  

  







  