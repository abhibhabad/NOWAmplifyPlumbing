import os
import json
import boto3
from boto3.dynamodb.conditions import Attr
from datetime import datetime, timezone

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

        # Extract userId and validate it
        user_id = body.get('userId')
        if not user_id:
            raise ValueError("Missing required field: userId")

        # Query the table to find the user by userId
        response = usertable.scan(
            FilterExpression=Attr('userId').eq(user_id)
        )
        items = response.get('Items')

        if not items:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': f"User with userId '{user_id}' not found"})
            }

        # Get the first matching item (assuming userId is unique)
        user_item = items[0]
        user_table_id = user_item['id']

        # Prepare update expression and attribute values
        update_expression = "SET updatedAt = :updatedAt"
        expression_attribute_values = {
            ':updatedAt': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
        }

        # Optional fields to update
        optional_fields = ['firstName', 'lastName', 'imageKey', 'userPhoneNumber']
        for field in optional_fields:
            if field in body and body[field] is not None:
                update_expression += f", {field} = :{field}"
                expression_attribute_values[f":{field}"] = body[field]

        # Update the item in DynamoDB
        usertable.update_item(
            Key={'id': user_table_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="UPDATED_NEW"
        )

        print("UserTable entry updated successfully")

        # Return a successful response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'User updated successfully', 'userId': user_id})
        }

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
