import json
import os
import uuid

def labelOnS3Upload(event, context):
    
    bucket = "imagelabeller-ssem-2022"
    region_name = 'eu-central-1'

    filesUploaded = event['Records']
    for file in filesUploaded:
        fileName = file["s3"]["object"]["key"]
        response = getLabelFromRekognition(fileName, region_name, bucket)
        
        imageLabels = []
        for label in response['Labels']:
            imageLabels.append(label["Name"].lower()+" " + str("%.2f" %label["Confidence"])+"%")

    # Add to DynamoDB
    addImageToLabelTableResponse = addImageToLabelTable(str(fileName),imageLabels,region_name)
    s3HandlerResponseBody = {
        "addImageToLabelTableResponse": addImageToLabelTableResponse
    }

    finalResponse = {
        "statusCode": 200,
        "body": json.dumps(s3HandlerResponseBody)
    }
    return finalResponse

def getLabelFromRekognition(fileName, region_name, bucket):
    import boto3
    rekognitionClient = boto3.client('rekognition', region_name=region_name)
    return rekognitionClient.detect_labels(Image={'S3Object':{'Bucket':bucket,'Name':fileName}},
        MaxLabels=5)
    

def addImageToLabelTable(fileName, labels, region_name):
    import boto3
    dynamodb = boto3.resource('dynamodb', region_name=region_name)
    imageLabelTable = dynamodb.Table('Image_to_label')
    item = {
                'filename': str(fileName),
                'labels': labels
            }

    # add image data to master MASTER_IMAGE_TABLE
    imageLabelTable.put_item(Item=item)
    print("image data added to Image_to_label TABLE")

    # create a response
    response = {
        "statusCode": 200,
        "body": json.dumps(item)
    }
    return response