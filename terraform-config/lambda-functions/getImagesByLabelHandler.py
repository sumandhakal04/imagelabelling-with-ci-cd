import json
import os
import uuid

def getImagesByLabel(event, context):
    
    requestFilename = event["Records"][0]["s3"]["object"]["key"]
    imageLabels = getImageLabelsFromDB(requestFilename = requestFilename)

    results = []
    if "Item" in imageLabels:
        result = {}
        result["filename"] = imageLabels["Item"]["filename"]
        result["labels"] = imageLabels["Item"]["labels"]
        
        results.append(result)

    response = {
        "statusCode": 200,
        "body": json.dumps(results)
    }

    return response

def getImageLabelsFromDB( requestFilename):
    import boto3
    region_name = 'eu-central-1'
    dynamodb = boto3.resource('dynamodb', region_name=region_name)
    ImagetoLabelTable = dynamodb.Table('Image_to_label')
    
    imageLabels = ImagetoLabelTable.get_item(
        Key={
            'filename': requestFilename
        }
    )
    return imageLabels
