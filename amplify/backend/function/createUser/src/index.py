import os
import json
import boto3
from datetime import datetime, timezone
import uuid

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
user_table_name = os.environ.get('API_NOW_USERTABLETABLE_NAME')
usertable = dynamodb.Table(user_table_name)

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
        required_fields = ['userId', 'firstName', 'lastName', 'userEmail', 'userPhoneNumber']
        missing_fields = [field for field in required_fields if not body.get(field)]
        if missing_fields:
            raise ValueError(f"Missing required fields: {', '.join(missing_fields)}")

        # Extract fields from the request
        user_id = body['userId']
        first_name = body['firstName']
        last_name = body['lastName']
        user_email = body['userEmail']
        user_phone_number = body['userPhoneNumber']

        # Generate IDs and timestamps
        user_table_id = str(uuid.uuid4()).upper()
        current_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
        unix_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)

        # Construct the item for DynamoDB
        user_item = {
            'id': user_table_id,
            '__typename': 'UserTable',
            '_version': 1,
            '_lastChangedAt': unix_timestamp,
            'createdAt': current_timestamp,
            'updatedAt': current_timestamp,
            'firstName': first_name,
            'lastName': last_name,
            'userEmail': user_email,
            'userId': user_id,
            'userPhoneNumber': user_phone_number
        }

        # Insert the item into the table
        usertable.put_item(Item=user_item)
        print("UserTable entry created successfully")

        # Return a successful response
        response = {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'User created successfully',
                'userId': user_table_id
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

