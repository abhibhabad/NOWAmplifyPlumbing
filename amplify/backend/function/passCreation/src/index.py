
import json
import os
import stripe
from botocore.exceptions import ClientError
import boto3
import logging
from datetime import datetime, timezone
import uuid
import base64


# Initialize Stripe and DynamoDB
table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
listing_t = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
ssm = boto3.client('ssm')  # Set your Stripe endpoint secret in environment variables
dynamodb = boto3.resource('dynamodb')
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
        print(f"Error fetching SSM parameter: {e}")
        raise Exception("Unable to fetch Stripe API key from SSM")

def handler(event, context):
    print("Recieved event:")
    print(event)
    # Extract the Stripe signature from headers
    stripe_signature = event['headers'].get('Stripe-Signature')
    print('Stripe signature: ' + stripe_signature)
    
    # Extract the body
    payload = event['body']

    endpoint_secret = get_stripe_endpoint_secret(os.environ.get('endpointSecret'))
    
    try:
        # Verify the event by constructing it with the endpoint secret and the signature
        print("Checking stripe thumbprint...")

        print("payload:"+payload)

        stripe_event = stripe.Webhook.construct_event(
            payload=payload, 
            sig_header=stripe_signature, 
            secret=endpoint_secret
        )


        
        # If event is successfully verified, proceed to handle it
        print('Stripe event verified successfully')
        
        # Handle the event (e.g., a charge succeeded event)
        if stripe_event['type'] == 'charge.succeeded':
            charge_data = stripe_event['data']['object']
            metadata = charge_data['metadata']

            # Extract metadata
            venue_id = metadata.get('venueId')
            listing_id = metadata.get('listingId')
            customer_id = metadata.get('customerId')
            purchase_type = metadata.get('type')

            print('Unpacking Event')

            print(venue_id, listing_id, customer_id, purchase_type)

            # Ensure the metadata exists
            if not venue_id or not listing_id or not customer_id:
                raise ValueError("Required metadata is missing in the event.")
            
            if purchase_type != 'NOWPASS':
                raise ValueError(f'Not of NOWPASS type, of type: {purchase_type}')
            
            pass_id = str(uuid.uuid4()).upper()
            
            current_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
            unix_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)
            
            # Prepare the item to insert into the PassesTable
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

            update_response = listing_table.update_item(
                Key={'id': listing_id},
                UpdateExpression="SET passesSold = if_not_exists(passesSold, :start) + :increment",
                ExpressionAttributeValues={
                    ':start': 0,
                    ':increment': 1
                },
                ReturnValues="UPDATED_NEW"
            )

            print(update_response)

            # Insert the item into DynamoDB
            response = passes_table.put_item(Item=pass_item)

            print(response)
            
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