
import json
import os
import stripe
from botocore.exceptions import ClientError
import boto3
import logging
from datetime import datetime, timezone
import uuid

# Initialize Stripe and DynamoDB
table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
listing_t = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
sms_lambda_name = os.environ['FUNCTION_INTERNALSMS_NAME']  # Environment variable for the SMS Lambda name
slack_lambda_name = os.environ['FUNCTION_INTERNALSLACK_NAME']

ssm = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')  # Client for invoking another Lambda

passes_table = dynamodb.Table(table_name)
listing_table = dynamodb.Table(listing_t)

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

def handler(event, context):
    print("Received event:", event)
    
    stripe_signature = event['headers'].get('Stripe-Signature')
    payload = event['body']
    endpoint_secret = get_stripe_endpoint_secret(os.environ.get('endpointSecret'))

    try:
        # Verify the Stripe event
        stripe_event = stripe.Webhook.construct_event(
            payload=payload,
            sig_header=stripe_signature,
            secret=endpoint_secret
        )
        logger.info('Stripe event verified successfully')

        if stripe_event['type'] == 'charge.succeeded':
            charge_data = stripe_event['data']['object']
            metadata = charge_data['metadata']

            print(f"metadata: {metadata}")

            # Extract necessary metadata
            venue_id = metadata.get('venueId')
            listing_id = metadata.get('listingId')
            customer_id = metadata.get('customerId')
            purchase_type = metadata.get('type', 'UNKNOWN')
            customer_name = metadata.get('customerName', 'UNKNOWN')

            # Ensure required metadata is present
            if not venue_id or not listing_id or not customer_id or purchase_type != 'NOWPASS':
                raise ValueError("Required metadata is missing or invalid.")

            pass_id = str(uuid.uuid4()).upper()
            current_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
            unix_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)


            # Create the pass item
            pass_item = {
                'id': pass_id,  # Generate a unique ID for the pass
                '__typename': 'PassesTable',  # Standard type name field
                '_version': 1,  # Initial version for new item
                '_lastChangedAt': unix_timestamp,  # Set to current timestamp
                'createdAt': current_timestamp,  # Timestamp when the pass was created
                'updatedAt': current_timestamp,  # Timestamp when the pass was last updated
                'passStatus': 'PURCHASED',  # Assuming 'ACTIVE' as the initial status
                'userID': customer_id,
                'purchasedAt': current_timestamp,  # Set the purchase time to current time
                'transactionID': charge_data['id'],  # Using Stripe charge ID as transaction ID
                'listingtableID': listing_id,
                'venuesID': venue_id
            }

            print(f"PASS CREATED: {pass_item}")

            # Update the listing to increment the passesSold count
            listing_table.update_item(
                Key={'id': listing_id},
                UpdateExpression="SET passesSold = if_not_exists(passesSold, :start) + :increment",
                ExpressionAttributeValues={
                    ':start': 0,
                    ':increment': 1
                }
            )

            # Insert the pass into DynamoDB
            passes_table.put_item(Item=pass_item)

            # Prepare metadata for the SMS Lambda
            sms_payload = {
                "venueId": venue_id,
                "listingId": listing_id,
                "customerName": customer_name
            }

            # Invoke SMS Lambda asynchronously
            try:
                lambda_client.invoke(
                    FunctionName=slack_lambda_name,
                    InvocationType='Event',  # Asynchronous invocation
                    Payload=json.dumps(sms_payload)
                )
                logger.info("SMS Lambda invoked successfully")
            except Exception as e:
                logger.error(f"Failed to invoke SMS Lambda: {e}")

            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Pass created successfully', 'passId': pass_item['id']})
            }

        else:
            logger.info(f"Unhandled event type {stripe_event['type']}")
            return {
                'statusCode': 400,
                'body': json.dumps({'message': f"Unhandled event type {stripe_event['type']}"})
            }

    except ValueError as e:
        logger.error(f"Signature verification failed: {str(e)}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Webhook signature verification failed'})
        }
    
    except Exception as e:
        logger.error(f"Error handling webhook: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
