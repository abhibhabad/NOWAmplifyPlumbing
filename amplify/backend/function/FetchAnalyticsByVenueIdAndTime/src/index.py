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
        start_date = now - timedelta(weeks=1)
    elif timeframe == 'month':
        start_date = now - timedelta(days=30)
    else:  # 'all' timeframe
        start_date = datetime.min  # Set to the earliest possible date

    return start_date, now

# Fetch the revenueSplit for the given venue
def get_venue_revenue_split(venue_id):
    response = venues_table.get_item(Key={'id': venue_id})
    venue = response.get('Item')
    if venue:
        return venue.get('revenueSplit', 0.85)  # Default to 85% if not set
    else:
        raise Exception(f"Venue with ID {venue_id} not found")

def query_listings_by_venue(venue_id):
    response = listings_table.query(
        IndexName='byVenues',  # Assuming you have a secondary index on venueID
        KeyConditionExpression=boto3.dynamodb.conditions.Key('venuesID').eq(venue_id)
    )
    return response['Items']

def query_passes_by_listing(listing_id, start_date):
    response = passes_table.query(
        IndexName='byListingTable',  # Assuming you have a secondary index on listingID
        KeyConditionExpression=boto3.dynamodb.conditions.Key('listingtableID').eq(listing_id),
        FilterExpression=boto3.dynamodb.conditions.Attr('purchasedAt').gte(start_date.isoformat())
    )
    return response['Items']

# Deduct Stripe fee and apply revenueSplit
def calculate_profit_after_fees(listing_price, revenue_split):
    net_price = listing_price - (listing_price * STRIPE_PERCENTAGE_FEE) - STRIPE_FIXED_FEE
    venue_profit = net_price * float(revenue_split)
    return venue_profit

def calculate_profit_and_sold(listings, start_date, revenue_split):
    profit_by_type = {}
    passes_sold_by_type = {}

    for listing in listings:
        listing_id = listing['id']
        listing_type = listing['listingType']
        listing_price = float(listing['listingPrice'])

        # Query passes for this listing
        passes = query_passes_by_listing(listing_id, start_date)

        # Calculate passes sold and profit
        passes_sold = len(passes)
        total_profit = 0

        for _ in passes:
            # Deduct Stripe fee and apply revenueSplit for each pass
            venue_profit = calculate_profit_after_fees(listing_price, revenue_split)
            total_profit += venue_profit

        # Update data by listingType
        if listing_type not in profit_by_type:
            profit_by_type[listing_type] = 0
            passes_sold_by_type[listing_type] = 0
        
        profit_by_type[listing_type] += total_profit
        passes_sold_by_type[listing_type] += passes_sold

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
    # Step 1: Query the listings by venueID
    listings = query_listings_by_venue(venue_id)

    print(f"LISTINGS: {listings}")

    # Step 2: Calculate profit and passes sold by type
    profit_by_type, passes_sold_by_type = calculate_profit_and_sold(listings, start_date, revenue_split)

    # Step 3: Return the results
    return {
        'statusCode': 200,
        'body': json.dumps({
            'venueID': venue_id,
            'timeframe': timeframe,
            'profitByType': profit_by_type,
            'passesSoldByType': passes_sold_by_type
        })
    }


