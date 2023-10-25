import boto3 
import json

COFFEE_POOL_TN = os.environ['COFFEE_POOL_TABLE_NAME']
REGION = os.environ['REGION']
dynamodb = boto3.resource('dynamodb', region_name=REGION)
coffee_pool_table = dynamodb.Table(COFFEE_POOL_TN)

def lambda_handler(event, context):
  
    with open('coffee_pool.json') as f:
        data = json.load(f)
    
    try:
        with coffee_pool_table.batch_writer() as batch:
            for coffee in data['coffee_pool']:
                batch.put_item(Item=coffee)
    except ClientError as e:
        print(f'Error: {e}')
    except Exception as e:
        print(f'Unexpected error: {e}')

    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': 'Coffe pool item list uploaded'
        })
    }
    
    return response