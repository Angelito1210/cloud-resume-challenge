import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitors-v2')   # ← Aquí estaba el error

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'total'},
        UpdateExpression='ADD #count :inc',
        ExpressionAttributeNames={'#count': 'count'},
        ExpressionAttributeValues={':inc': 1},
        ReturnValues='UPDATED_NEW'
    )
    count = response['Attributes']['count']
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({'count': int(count)})
    }
