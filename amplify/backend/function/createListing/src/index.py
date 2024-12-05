import os
import json
import boto3
from datetime import datetime, timezone
import uuid

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
listing_table_name = os.environ.get('API_NOW_LISTINGTABLETABLE_NAME')
listingtable = dynamodb.Table(listing_table_name)

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
            'listingName', 'listingType', 'listingStart', 'listingEnd', 'totalPasses',
            'instructions', 'description', 'createdBy', 'venuesID', 'venueName',
            'listingPrice'
        ]
        missing_fields = [field for field in required_fields if field not in body]
        if missing_fields:
            raise ValueError(f"Missing required fields: {', '.join(missing_fields)}")

        # Extract fields from the request
        listing_name = body['listingName']
        listing_type = body['listingType']
        listing_start = body['listingStart']
        listing_end = body['listingEnd']
        total_passes = body['totalPasses']
        passes_sold = body.get('passesSold', 0)  # Default to 0 if not provided
        instructions = body['instructions']
        description = body['description']
        created_by = body['createdBy']
        venues_id = body['venuesID']
        venue_name = body['venueName']
        listing_price = body['listingPrice']
        is_active = body.get('isActive', True)  # Default to True if not provided
        is_expired = body.get('isExpired', False)  # Default to False if not provided

        # Generate IDs and timestamps
        listing_table_id = str(uuid.uuid4()).upper()
        current_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'
        unix_timestamp = int(datetime.now(timezone.utc).timestamp() * 1000)

        # Construct the item for DynamoDB
        listing_item = {
            'id': listing_table_id,
            '__typename': 'ListingTable',
            '_version': 1,
            '_lastChangedAt': unix_timestamp,
            'createdAt': current_timestamp,
            'updatedAt': current_timestamp,
            'listingName': listing_name,
            'listingType': listing_type,
            'listingStart': listing_start,
            'listingEnd': listing_end,
            'totalPasses': total_passes,
            'passesSold': passes_sold,
            'instructions': instructions,
            'description': description,
            'createdBy': created_by,
            'venuesID': venues_id,
            'venueName': venue_name,
            'isActive': is_active,
            'listingPrice': listing_price,
            'isExpired': is_expired
        }

        # Insert the item into the table
        listingtable.put_item(Item=listing_item)
        print("ListingTable entry created successfully")

        # Return a successful response
        response = {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Listing created successfully',
                'listingId': listing_table_id
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