import os
import boto3
from datetime import datetime, timezone
from pytz import timezone, UTC

# Initialize DynamoDB resources
dynamodb = boto3.resource('dynamodb')

listing_table = dynamodb.Table(os.environ['API_NOW_LISTINGTABLETABLE_NAME'])
passes_table = dynamodb.Table(os.environ['API_NOW_PASSESTABLETABLE_NAME'])

def handler(event, context):

    print(f"Recieved event: \n\n {event}")

    # Set the timezone for EST
    est_tz = timezone('US/Eastern')
    current_time = datetime.now(est_tz)

    # Step 1: Query active listings (isExpired = false) from the Listing Table
    listing_response = listing_table.scan(
        FilterExpression='isExpired = :expired',
        ExpressionAttributeValues={':expired': False}
    )
    active_listings = listing_response['Items']

    print(f"Found active listings: {active_listings}")

    

    # Step 2: Process each active listing
    for listing in active_listings:
        
        listing_end_time_str = listing['listingEnd']  # Sample format: '2024-10-21T09:00:00.000Z'
        # Use strptime to parse the ISO 8601 datetime with Z
        listing_end_time = datetime.strptime(listing_end_time_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=UTC)


        if listing_end_time < current_time:
            print(f"Found Listing to set to inactive: {listing}")
            # Step 3: If the listing end time is before the current time, toggle isExpired = true, isActive = false
            listing_table.update_item(
                Key={'id': listing['id']},
                UpdateExpression='SET isExpired = :expired, isActive = :active',
                ExpressionAttributeValues={
                    ':expired': True,
                    ':active': False
                    }
            )

            print(f"Listing successfully set to expired and inactive: {listing}")



            # Step 4: Query the PassesTable for all passes with passStatus = 'ACTIVE' for that listing
            pass_response = passes_table.query(
                IndexName='byListingTable',  # Assuming there's a GSI on listingId
                KeyConditionExpression='listingtableID = :listingtableID',
                ExpressionAttributeValues={':listingtableID': listing['id']}
            )
            passes = pass_response['Items']

            print(f"Found passes in listing: {passes}")

            # Step 5: Update passStatus to 'EXPIRED' for all active passes
            for pass_item in passes:
                if pass_item['passStatus'] == 'PURCHASED':
                    print(f"EXPIRING: {pass_item}")
                    passes_table.update_item(
                        Key={'id': pass_item['id']},
                        UpdateExpression='SET passStatus = :expired',
                        ExpressionAttributeValues={':expired': 'EXPIRED'}
                    )
                    print(f"EXPIRED: {pass_item}")
    
    return {
        'statusCode': 200,
        'body': 'Listings and passes updated successfully.'
    }
