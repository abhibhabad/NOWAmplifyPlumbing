import os
import json
import boto3
from datetime import datetime, timezone
import uuid
from decimal import Decimal

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
venue_table_name = os.environ.get('API_NOW_VENUESTABLE_NAME')
venue_table = dynamodb.Table(venue_table_name)

def handler(event, context):
    try:
        print("Received event: " + json.dumps(event))

        # Validate and parse the body
        body = event.get('body')
        if not body:
            raise ValueError("No body in the event")

        try:
            body = json.loads(body)
        except json.JSONDecodeError:
            raise ValueError("Invalid JSON format in the request body")

        # Extract and validate required fields
        required_fields = [
            'venueName', 'venuePhoneNumber', 'venueEmail', 'venueImageKey',
            'venueHours', 'accountName', 'EIN', 'accountNumber', 'routingNumber',
            'ownerFirstName', 'ownerLastName', 'ownerEmail', 'ownerPhoneNumber',
            'createdBy', 'revenueSplit', 'daysOfOperation'
        ]
        missing_fields = [field for field in required_fields if not body.get(field)]
        if missing_fields:
            raise ValueError(f"Missing required fields: {', '.join(missing_fields)}")

        # Extract fields from the request
        venue_name = body['venueName']
        venue_phone_number = body['venuePhoneNumber']
        venue_email = body['venueEmail']
        venue_image_key = body['venueImageKey']
        venue_hours = body['venueHours']
        account_name = body['accountName']
        ein = int(body['EIN'])
        account_number = int(body['accountNumber'])
        routing_number = int(body['routingNumber'])
        owner_first_name = body['ownerFirstName']
        owner_last_name = body['ownerLastName']
        owner_email = body['ownerEmail']
        owner_phone_number = body['ownerPhoneNumber']
        created_by = body['createdBy']
        revenue_split = Decimal(str(body['revenueSplit']))  # Convert to Decimal
        days_of_operation = body['daysOfOperation']

        # Generate IDs and timestamps
        venue_id = str(uuid.uuid4()).upper()
        current_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
        unix_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)

        # Construct the item for DynamoDB
        venue_item = {
            'id': venue_id,
            '__typename': 'Venues',
            '_version': 1,
            '_lastChangedAt': unix_timestamp,
            'createdAt': current_timestamp,
            'updatedAt': current_timestamp,
            'venueName': venue_name,
            'venuePhoneNumber': venue_phone_number,
            'venueEmail': venue_email,
            'venueImageKey': venue_image_key,
            'venueHours': venue_hours,
            'accountName': account_name,
            'EIN': ein,
            'accountNumber': account_number,
            'routingNumber': routing_number,
            'ownerFirstName': owner_first_name,
            'ownerLastName': owner_last_name,
            'ownerEmail': owner_email,
            'ownerPhoneNumber': owner_phone_number,
            'createdBy': created_by,
            'revenueSplit': revenue_split,  # Use Decimal type
            'daysOfOperation': days_of_operation
        }

        # Insert the item into the table
        venue_table.put_item(Item=venue_item)
        print("Venues entry created successfully")

        # Return a successful response
        response = {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Venue created successfully',
                'venueId': venue_id
            })
        }
        return response

    except ValueError as e:
        print(f"Validation error: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }

    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }