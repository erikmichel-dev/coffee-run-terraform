import os
import json
import random

COFFEE_POOL_TN = os.environ['COFFEE_POOL_TABLE_NAME']
TIER_LIST_TN = os.environ['TIER_LIST_TABLE_NAME']
REGION = os.environ['REGION']
dynamodb = boto3.resource('dynamodb', region_name=REGION)
coffee_pool_table = dynamodb.Table(COFFEE_POOL_TN)
tier_list_table = dynamodb.Table(TIER_LIST_TN)

def lambda_handler(event, context):
    
    drop_chance = {
        "common": 40,
        "uncommon": 25,
        "rare": 18,
        "epic": 12,
        "legendary": 5
    }
    
    # Generate a random number between 1 and 100
    random_number = random.randint(1, 100)

    # Determine the rarity category based on the random number
    if random_number <= drop_chance["common"]:
        rarity = "common"
    elif random_number <= drop_chance["common"] + drop_chance["uncommon"]:
        rarity = "uncommon"
    elif random_number <= drop_chance["common"] + drop_chance["uncommon"] + drop_chance["rare"]:
        rarity = "rare"
    elif random_number <= drop_chance["common"] + drop_chance["uncommon"] + drop_chance["rare"] + drop_chance["epic"]:
        rarity = "epic"
    else:
        rarity = "legendary"

    # Retrieve 

    response = tier_list_table.get_item(Key={'tier_id': rarity})
    tier_amount = response['Item']['amount']
    random_id = random.randint(1, tier_amount)

    response = coffee_pool_table.get_item(Key={'coffee_id': random_id})
    coffee_drop = response['Item']

    # Create the response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': f'{coffee_drop}'
        })
    }
    
    return response
