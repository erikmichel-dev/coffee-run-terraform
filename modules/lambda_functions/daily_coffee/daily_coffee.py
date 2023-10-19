import json
import random

def lambda_handler(event, context):
    # Array of 10 strings
    string_array = [
        "Americano",
        "Cappuccino",
        "Espresso",
        "Latte",
        "Mocha",
        "Macchiato",
        "Flat White",
        "Ristretto",
        "Affogato",
        "Cold Brew"
    ]
    
    # Select a random string from the array
    random_string = random.choice(string_array)
    
    # Create the response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': f'{random_string}'
        })
    }
    
    return response
