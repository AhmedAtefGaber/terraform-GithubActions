import json

def lambda_handler(event, context):
    '''
    The handler function is the starting point of your code.
    It's the python function that is executed when your lambda function runs.
    event is the data that's passed to the function upon execution like body, Http method, etc..
    '''
    request_details = { "Response": "Welcome to our demo API, here are the details of your request:", "Method": json.dumps(event["httpMethod"]), "Headers": json.dumps(event["headers"]["Content-Type"]), "body": json.dumps(event["body"])}
    return {'statusCode': 200, "body": json.dumps(request_details)}
    