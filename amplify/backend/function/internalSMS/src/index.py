import json
import os
import stripe
from botocore.exceptions import ClientError
import boto3
import logging
from datetime import datetime, timezone
import pytz

# Initialize Stripe and DynamoDB
table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
listing_t = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
venue_t = os.environ['API_NOW_VENUESTABLE_NAME']
sns_number = "8608798849"  # Add your target phone number here

ssm = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

passes_table = dynamodb.Table(table_name)
listing_table = dynamodb.Table(listing_t)
venue_table = dynamodb.Table(venue_t)

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_stripe_endpoint_secret(name):
    """Fetch Stripe Endpoint Secret from SSM Parameter Store."""
    try:
        parameter = ssm.get_parameter(Name=name, WithDecryption=True)
        return parameter['Parameter']['Value']
    except ClientError as e:
        logger.error(f"Error fetching SSM parameter: {e}")
        raise Exception("Unable to fetch Stripe API key from SSM")

def query_table(table, key, key_value, projection):
    """Helper function to query DynamoDB table."""
    try:
        response = table.get_item(Key={key: key_value}, ProjectionExpression=projection)
        return response['Item'][projection] if 'Item' in response else None
    except ClientError as e:
        logger.error(f"Error querying table: {e}")
        return None

def handler(event, context):
    print("Received event:", event)
    
    # Extract Stripe signature and payload
    stripe_signature = event['headers'].get('Stripe-Signature')
    payload = event['body']
    endpoint_secret = get_stripe_endpoint_secret(os.environ.get('endpointSecret'))

    try:
        stripe_event = stripe.Webhook.construct_event(payload=payload, sig_header=stripe_signature, secret=endpoint_secret)
        logger.info('Stripe event verified successfully')

        if stripe_event['type'] == 'charge.succeeded':
            charge_data = stripe_event['data']['object']
            metadata = charge_data['metadata']

            # Extract metadata
            venue_id = metadata.get('venueId')
            listing_id = metadata.get('listingId')
            customer_name = metadata.get('customerName', "Valued Customer")

            # Query venue and listing names
            venue_name = query_table(venue_table, 'id', venue_id, 'venueName')
            listing_name = query_table(listing_table, 'id', listing_id, 'listingName')
            listing_start = query_table(listing_table, 'id', listing_id, 'listingStart')

            listing_date_obj = datetime.strptime(listing_start, '%Y-%m-%dT%H:%M:%S.%fZ')
            formatted_date = listing_date_obj.strftime('%m/%d')

            if venue_name and listing_name:
                # Construct message
                est = pytz.timezone('America/New_York')
                timestamp = datetime.now(est).strftime('%I:%M %p EST %m/%d/%Y')
                message = f"\n{customer_name} just purchased a pass for {listing_name} ({formatted_date}) at {venue_name} at {timestamp}"

                # Send SMS via SNS
                try:
                    sns.publish(
                        TopicArn='arn:aws:sns:us-east-1:227321529976:InternalNotifications',
                        Message=message
                    )
                    logger.info("Message sent successfully")
                    return {
                        'statusCode': 200,
                        'body': json.dumps({'message': 'Message sent!'})
                    }
                except ClientError as e:
                    logger.error(f"Error sending SMS: {e}")
                    return {
                        'statusCode': 500,
                        'body': json.dumps({'message': 'Failed to send message'})
                    }
            else:
                logger.error("Venue or listing name not found.")
                return {
                    'statusCode': 404,
                    'body': json.dumps({'message': 'Venue or listing not found'})
                }

        else:
            logger.info(f"Unhandled event type {stripe_event['type']}")
            return {
                'statusCode': 400,
                'body': json.dumps({'message': f"Unhandled event type {stripe_event['type']}"})
            }

    except stripe.error.SignatureVerificationError as e:
        logger.error(f"Signature verification failed: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Signature verification failed'})
        }
