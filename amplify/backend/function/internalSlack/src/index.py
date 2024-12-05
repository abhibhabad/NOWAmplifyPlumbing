import json
import os
import boto3
from botocore.exceptions import ClientError
import logging
from datetime import datetime
import pytz
import requests

# Initialize DynamoDB
table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
listing_t = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
venue_t = os.environ['API_NOW_VENUESTABLE_NAME']

ssm = boto3.client('ssm')

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_slack_token(name):
    """Fetch Slack Bot Token from SSM Parameter Store."""
    try:
        parameter = ssm.get_parameter(Name=name, WithDecryption=True)
        return parameter['Parameter']['Value']
    except ClientError as e:
        logger.error(f"Error fetching SSM parameter: {e}")
        raise Exception("Unable to fetch Slack API key from SSM")

# Fetch Slack token
slack_token = get_slack_token(os.environ.get('slackBotToken'))

# Initialize DynamoDB resources
dynamodb = boto3.resource('dynamodb')
passes_table = dynamodb.Table(table_name)
listing_table = dynamodb.Table(listing_t)
venue_table = dynamodb.Table(venue_t)

def query_table(table, key, key_value, projection):
    """Helper function to query DynamoDB table."""
    try:
        response = table.get_item(Key={key: key_value}, ProjectionExpression=projection)
        return response['Item'][projection] if 'Item' in response else None
    except Exception as e:
        logger.error(f"Error querying table: {e}")
        return None

def slack_channel_exists(channel_name):
    """Check if a Slack channel exists."""
    url = "https://slack.com/api/conversations.list"
    headers = {"Authorization": f"Bearer {slack_token}"}
    response = requests.get(url, headers=headers)
    logger.info(f"Slack API Response for conversations.list: {response.status_code} - {response.text}")
    if response.status_code == 200:
        channels = response.json().get('channels', [])
        for channel in channels:
            if channel['name'] == channel_name:
                return channel['id']
    return None

def create_slack_channel(channel_name):
    """Create a Slack channel."""
    sanitized_name = channel_name.lower().replace(" ", "-").replace("_", "-")
    url = "https://slack.com/api/conversations.create"
    headers = {"Authorization": f"Bearer {slack_token}"}
    payload = {"name": sanitized_name}
    response = requests.post(url, headers=headers, json=payload)
    logger.info(f"Slack API Response for conversations.create: {response.status_code} - {response.text}")
    if response.status_code == 200:
        response_data = response.json()
        if response_data.get('ok'):
            return response_data.get('channel', {}).get('id')
        else:
            logger.error(f"Error creating Slack channel: {response_data['error']}")
    else:
        logger.error(f"HTTP error: {response.status_code} - {response.text}")
    return None

def get_all_users():
    """Fetch all users in the Slack workspace."""
    url = "https://slack.com/api/users.list"
    headers = {"Authorization": f"Bearer {slack_token}"}
    response = requests.get(url, headers=headers)
    logger.info(f"Slack API Response for users.list: {response.status_code} - {response.text}")
    if response.status_code == 200:
        response_data = response.json()
        if response_data.get('ok'):
            return [user['id'] for user in response_data['members'] if not user['deleted'] and not user['is_bot']]
        else:
            logger.error(f"Error fetching users: {response_data['error']}")
    else:
        logger.error(f"HTTP error: {response.status_code} - {response.text}")
    return []

def invite_users_to_channel(channel_id, user_ids):
    """Invite a list of users to a Slack channel."""
    url = "https://slack.com/api/conversations.invite"
    headers = {"Authorization": f"Bearer {slack_token}"}
    for user_id in user_ids:
        payload = {"channel": channel_id, "users": user_id}
        response = requests.post(url, headers=headers, json=payload)
        logger.info(f"Slack API Response for conversations.invite (user {user_id}): {response.status_code} - {response.text}")
        if response.status_code == 200:
            response_data = response.json()
            if not response_data.get('ok'):
                logger.error(f"Error inviting user {user_id}: {response_data['error']}")
        else:
            logger.error(f"HTTP error: {response.status_code} - {response.text}")

def post_to_slack(channel_id, message):
    """Post a message to a Slack channel."""
    url = "https://slack.com/api/chat.postMessage"
    headers = {"Authorization": f"Bearer {slack_token}"}
    payload = {"channel": channel_id, "text": message}
    response = requests.post(url, headers=headers, json=payload)
    logger.info(f"Slack API Response for chat.postMessage: {response.status_code} - {response.text}")
    if response.status_code == 200:
        logger.info(f"Message posted successfully to channel {channel_id}")
    else:
        logger.error(f"Error posting to Slack: {response.text}")

def handler(event, context):
    logger.info("Received event: %s", event)
    
    venue_id = event.get('venueId')
    listing_id = event.get('listingId')
    customer_name = event.get('customerName')

    venue_name = query_table(venue_table, 'id', venue_id, 'venueName')
    listing_name = query_table(listing_table, 'id', listing_id, 'listingName')
    listing_start = query_table(listing_table, 'id', listing_id, 'listingStart')
    listing_passes_sold = query_table(listing_table, 'id', listing_id, 'passesSold')
    listing_total_passes = query_table(listing_table, 'id', listing_id, 'totalPasses')

    if not listing_start:
        logger.error("Listing start date not found.")
        return {'statusCode': 404, 'body': json.dumps({'message': 'Listing start date not found'})}

    listing_date_obj = datetime.strptime(listing_start, '%Y-%m-%dT%H:%M:%S.%fZ')
    formatted_date = listing_date_obj.strftime('%m/%d')

    if venue_name and listing_name:
        est = pytz.timezone('America/New_York')
        timestamp = datetime.now(est).strftime('%I:%M %p EST %m/%d')
        message = (
            f"NOW\n\n{customer_name} just purchased a pass for:\n\n"
            f"{listing_name} ({formatted_date}) \n\nat:\n\n"
            f"{venue_name} at {timestamp}\n\nPasses sold: ({listing_passes_sold}/{listing_total_passes})"
        )

        # Check if Slack channel exists or create it
        channel_name = venue_name.lower().replace(" ", "-") + "-internal-notifications"
        channel_id = slack_channel_exists(channel_name)
        if not channel_id:
            channel_id = create_slack_channel(channel_name)
             # Invite all users to the channel
            user_ids = get_all_users()
            invite_users_to_channel(channel_id, user_ids)
            if not channel_id:
                return {'statusCode': 500, 'body': json.dumps({'message': 'Failed to create Slack channel'})}

        # Post the message to the Slack channel
        post_to_slack(channel_id, message)
        return {'statusCode': 200, 'body': json.dumps({'message': 'Message sent to Slack!'})}
    else:
        logger.error("Venue or listing name not found.")
        return {'statusCode': 404, 'body': json.dumps({'message': 'Venue or listing not found'})}
