import json
import os

minimum_version = os.environ['MINIMUM_VERSION']

def handler(event, context):  
  return {
      'statusCode': 200,
      'body': json.dumps(minimum_version)
  }