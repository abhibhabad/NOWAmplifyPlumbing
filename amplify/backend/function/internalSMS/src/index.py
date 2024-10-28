import json
import os
import boto3
import logging
from datetime import datetime
import pytz

# Initialize DynamoDB and SNS
table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
listing_t = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
venue_t = os.environ['API_NOW_VENUESTABLE_NAME']
sns_number = "8608798849"  # Add your target phone number here

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

passes_table = dynamodb.Table(table_name)
listing_table = dynamodb.Table(listing_t)
venue_table = dynamodb.Table(venue_t)

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

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
    
    # Extract metadata directly from the incoming event
    venue_id = event.get('venueId')
    listing_id = event.get('listingId')
    customer_name = event.get('customerName')

    # Query venue and listing names
    venue_name = query_table(venue_table, 'id', venue_id, 'venueName')
    listing_name = query_table(listing_table, 'id', listing_id, 'listingName')
    listing_start = query_table(listing_table, 'id', listing_id, 'listingStart')
    listing_passes_sold = query_table(listing_table, 'id', listing_id, 'passesSold')
    listing_total_passes = query_table(listing_table, 'id', listing_id, 'totalPasses')

    if not listing_start:
        logger.error("Listing start date not found.")
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Listing start date not found'})
        }

    # Format listing date as MM/DD
    listing_date_obj = datetime.strptime(listing_start, '%Y-%m-%dT%H:%M:%S.%fZ')
    formatted_date = listing_date_obj.strftime('%m/%d')

    if venue_name and listing_name:
        # Construct message
        est = pytz.timezone('America/New_York')
        timestamp = datetime.now(est).strftime('%I:%M %p EST %m/%d')
        message = (
            f"NOW\n\n{customer_name} just purchased a pass for:\n\n"
            f"{listing_name} ({formatted_date}) \n\nat:\n\n"
            f"{venue_name} at {timestamp}\n\nPasses sold: ({listing_passes_sold}/{listing_total_passes})"
        )

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
