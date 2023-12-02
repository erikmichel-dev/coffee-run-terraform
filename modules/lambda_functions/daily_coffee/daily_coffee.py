import os
import json
import random
import boto3

COFFEE_POOL_TN = os.environ['COFFEE_POOL_TABLE_NAME']
TIER_LIST_TN = os.environ['TIER_LIST_TABLE_NAME']
REGION = os.environ['REGION']
dynamodb = boto3.resource('dynamodb', region_name=REGION)
coffee_pool_table = dynamodb.Table(COFFEE_POOL_TN)
tier_list_table = dynamodb.Table(TIER_LIST_TN)

def lambda_handler(event, context):
    
    drop_chance = {
        "Common": 40,
        "Uncommon": 25,
        "Rare": 18,
        "Epic": 12,
        "Legendary": 5
    }
    
    # Generate a random number between 1 and 100
    random_number = random.randint(1, 100)

    # Determine the rarity category based on the random number
    if random_number <= drop_chance["Common"]:
        rarity = "Common"
    elif random_number <= drop_chance["Common"] + drop_chance["Uncommon"]:
        rarity = "Uncommon"
    elif random_number <= drop_chance["Common"] + drop_chance["Uncommon"] + drop_chance["Rare"]:
        rarity = "Rare"
    elif random_number <= drop_chance["Common"] + drop_chance["Uncommon"] + drop_chance["Rare"] + drop_chance["Epic"]:
        rarity = "Epic"
    else:
        rarity = "Legendary"

    # Retrieve 

    response = tier_list_table.get_item(Key={'tier_id': rarity})
    print('TEST')
    print(response)
    tier_amount = response['Item']['amount']
    print(tier_amount)
    random_id = random.randint(1, tier_amount)

    response = coffee_pool_table.get_item(Key={'coffee_id': str(random_id), 'tier': rarity})
    print(response)
    coffee_drop = response['Item']
    
    # Create the response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': True,
            'Access-Control-Allow-Methods': 'OPTIONS, POST, GET, PUT, DELETE',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
        'body': json.dumps(coffee_drop)
    }
    
    return response
