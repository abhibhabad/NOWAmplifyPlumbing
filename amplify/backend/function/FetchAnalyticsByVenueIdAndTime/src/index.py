import json
import boto3
import os
from datetime import datetime, timedelta

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')

listing_table_name = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
passes_table_name = os.environ['API_NOW_PASSESTABLETABLE_NAME']
venues_table_name = os.environ['API_NOW_VENUESTABLE_NAME']

# Tables
listings_table = dynamodb.Table(listing_table_name)
passes_table = dynamodb.Table(passes_table_name)
venues_table = dynamodb.Table(venues_table_name)

# Stripe fee constants
STRIPE_PERCENTAGE_FEE = 0.029
STRIPE_FIXED_FEE = 0.30

# Helper function to calculate the timeframe
def get_timeframe_dates(timeframe):
    now = datetime.now()

    if timeframe == 'day':
        start_date = now - timedelta(days=1)
    elif timeframe == 'week':
        # Get the current week's Monday (start of the week)
        start_of_week = now - timedelta(days=now.weekday())
        start_date = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0)
        
        # Get the end of the week (Sunday at 11:59 PM)
        end_date = start_date + timedelta(days=6, hours=23, minutes=59, seconds=59)
    elif timeframe == 'month':
        start_date = now - timedelta(days=30)
        end_date = now
    else:  # 'all' timeframe
        start_date = datetime.min  # Set to the earliest possible date
        end_date = now

    return start_date, end_date

# Fetch the revenueSplit for the given venue
def get_venue_revenue_split(venue_id):
    response = venues_table.get_item(Key={'id': venue_id})
    venue = response.get('Item')
    if venue:
        return venue.get('revenueSplit', 0.85)  # Default to 85% if not set
    else:
        raise Exception(f"Venue with ID {venue_id} not found")

# Query passes by venueID and timeframe
def query_passes_by_venue(venue_id, start_date):
    response = passes_table.query(
        IndexName='byVenues',  # Assuming you have a secondary index on venuesID
        KeyConditionExpression=boto3.dynamodb.conditions.Key('venuesID').eq(venue_id),
        FilterExpression=boto3.dynamodb.conditions.Attr('purchasedAt').gte(start_date.isoformat())
    )
    return response['Items']

# Batch get listings to retrieve listingType and listingPrice by listingID
def get_listings_details(listing_ids):
    keys = [{'id': listing_id} for listing_id in listing_ids]
    response = dynamodb.batch_get_item(
        RequestItems={
            listing_table_name: {
                'Keys': keys,
                'ProjectionExpression': 'id, listingType, listingPrice'
            }
        }
    )
    listings = response.get('Responses', {}).get(listing_table_name, [])
    return {listing['id']: listing for listing in listings}

# Deduct Stripe fee and apply revenueSplit conditionally
def calculate_profit_after_fees(listing_price, revenue_split, listing_type):
    # Deduct Stripe fees
    net_price = listing_price - (listing_price * STRIPE_PERCENTAGE_FEE) - STRIPE_FIXED_FEE
    
    # Apply revenueSplit only if listingType is "LINESKIP"
    if listing_type == "LINESKIP":
        return net_price * float(revenue_split)
    else:
        return net_price

def calculate_profit_and_sold_from_passes(passes, listings_data, revenue_split):
    profit_by_type = {}
    passes_sold_by_type = {}

    for pass_item in passes:
        listing_id = pass_item['listingtableID']
        listing_data = listings_data.get(listing_id)
        
        if not listing_data:
            continue  # Skip if listing data is not found for the pass
        
        listing_type = listing_data['listingType']
        listing_price = float(listing_data['listingPrice'])

        # Calculate profit based on listing type
        venue_profit = calculate_profit_after_fees(listing_price, revenue_split, listing_type)

        # Update profit and sold counts by listing type
        if listing_type not in profit_by_type:
            profit_by_type[listing_type] = 0
            passes_sold_by_type[listing_type] = 0
        
        profit_by_type[listing_type] += venue_profit
        passes_sold_by_type[listing_type] += 1

    return profit_by_type, passes_sold_by_type

def handler(event, context):
    print("Received Event: " + json.dumps(event))
    
    body = event.get('body')
    if body:
        body = json.loads(body)
        venue_id = body.get('venueID')
        timeframe = body.get('timeframe')
    
        if not venue_id:
            return {
                'statusCode': 400,
                'body': json.dumps('Bad Request: venueId is missing')
            }

    start_date, end_date = get_timeframe_dates(timeframe)

    # Fetch revenueSplit from Venues table
    revenue_split = get_venue_revenue_split(venue_id)

    # Query the passes by venueID and start_date directly
    passes = query_passes_by_venue(venue_id, start_date)

    # Extract unique listing IDs from passes
    unique_listing_ids = list({pass_item['listingtableID'] for pass_item in passes})

    # Get listing details for these unique IDs
    listings_data = get_listings_details(unique_listing_ids)

    # Calculate profit and passes sold by type
    profit_by_type, passes_sold_by_type = calculate_profit_and_sold_from_passes(passes, listings_data, revenue_split)

    # Return the results
    return {
        'statusCode': 200,
        'body': json.dumps({
            'venueID': venue_id,
            'timeframe': timeframe,
            'profitByType': profit_by_type,
            'passesSoldByType': passes_sold_by_type
        })
    }

