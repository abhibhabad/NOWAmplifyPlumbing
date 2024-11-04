import os
import boto3
import json
import stripe
from botocore.exceptions import ClientError

table_name = os.environ['API_NOW_LISTINGTABLETABLE_NAME']
ssm = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')
listing_table = dynamodb.Table(table_name)

def get_stripe_api_key(name):
    """Fetch Stripe API key from SSM Parameter Store."""
    try:
        parameter = ssm.get_parameter(Name=name, WithDecryption=True)
        return parameter['Parameter']['Value']
    except ClientError as e:
        print(f"Error fetching SSM parameter: {e}")
        raise Exception("Unable to fetch Stripe API key from SSM")

def get_listing(listing_id):
    """Fetch listing details from DynamoDB by listingId."""
    try:
        response = listing_table.get_item(Key={'id': listing_id})
        if 'Item' in response:
            return response['Item']
        else:
            raise Exception(f"Listing with ID {listing_id} not found.")
    except ClientError as e:
        print(f"Error fetching listing: {e}")
        raise Exception(f"Unable to fetch listing with ID {listing_id}")

def create_payment_intent(amount_in_cents, purchaseType, listing_id, venue_id, customer_id, customer_name):
    try:
        # Initialize Stripe API key
        stripe_api_key = get_stripe_api_key(os.environ.get('stripeAPIKEY'))
        stripe.api_key = stripe_api_key

        # Create a payment intent
        payment_intent = stripe.PaymentIntent.create(
            amount=amount_in_cents,  # Amount in cents
            currency='usd',
            payment_method_types=['card'],  # Apple Pay goes through 'card'

            metadata={
                'type': purchaseType,
                'customerId': customer_id,
                'listingId': listing_id,
                'venueId': venue_id,
                'customerName': customer_name
            }
        )
        return payment_intent.client_secret
    
    except Exception as e:
        print(f"Error creating payment intent: {e}")
        raise Exception("Failed to create payment intent")

def handler(event, context):
    print(f"Received event: \n\n {event}")
    try:
        body = event.get('body')
        if body:
            body = json.loads(body)
            listing_id = body.get('listingId')
            venue_id = body.get('venueID')
            customer_id = body.get('customerID')
            amount = body.get('listingAmount')
            purchaseType = body.get('purchaseType')
            customer_name = body.get('customerName')


        print(f"Retrieving Client Secret for Listing: {listing_id} and Amount: {amount}")

        if not listing_id or not venue_id or not customer_id or not purchaseType or not amount:
            return {
                'statusCode': 503,
                'body': json.dumps({'error': f"Need listing_id venue_id customer_id purchaseType amount"})
            }
        
        # Fetch the listing from DynamoDB
        listing = get_listing(listing_id)

        # Check if the listing is active and not expired
        if listing.get('isExpired', True):
            return {
                'statusCode': 501,
                'body': json.dumps({'error': f"Listing {listing_id} is expired."})
            }
        
        if not listing.get('isActive', False):
            return {
                'statusCode': 502,
                'body': json.dumps({'error': f"Listing {listing_id} is not active."})
            }
        
        listing_passes_sold = listing.get('passesSold')
        listing_passes_total = listing.get('totalPasses')
        listing_type = listing.get('listingType')

        print(f"Passes sold: {listing_passes_sold}")
        print(f"Passes total: {listing_passes_total}")

        if listing_passes_sold >= listing_passes_total and listing_type != "COVER":
            return {
                'statusCode': 504,
                'body': json.dumps({'error': f"Listing {listing_id} is sold out"})
            }
        
        # Fetch listing price
        listing_price = listing.get('listingPrice')
        
        # Calculate total price in cents
        total_price_in_cents = int(listing_price * amount * 100) 
        
        # Generate the payment intent
        client_secret = create_payment_intent(total_price_in_cents, purchaseType, listing_id, venue_id, customer_id, customer_name)


        return {
            'statusCode': 200,
            'body': json.dumps({
                'clientSecret': client_secret
            })
        }

    except Exception as e:
        print(f"Error in lambda_handler: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

