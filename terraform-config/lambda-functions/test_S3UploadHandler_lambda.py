import re
import unittest
from unittest import mock

from S3UploadHandler import labelOnS3Upload

def mocked_getLabelFromRekognition(fileName, region_name, bucket):
    return {
        "Labels": [
            {"Name": "Furniture", "Confidence": 99.89},
            {"Name": "Chair", "Confidence": 99.0},
            {"Name": "Dining Table", "Confidence": 98.89},
            {"Name": "Table", "Confidence": 97.89},
            {"Name": "Wood", "Confidence": 96.89}
        ]
    }

def mocked_addImageToLabelTable(requestfileName, labels, region_nameFilename):
    return {
        "statusCode": 200,
        "body": "{\"filename\": \"album1/images.jpg\", \"labels\": [\"furniture 99.89%\", \"chair 99.00%\", \"dining table 98.89%\", \"table 97.89%\", \"wood 96.89%\"]}"
    }

class test_S3UploadHandler(unittest.TestCase):

    @mock.patch('S3UploadHandler.getLabelFromRekognition', side_effect =mocked_getLabelFromRekognition)
    @mock.patch('S3UploadHandler.addImageToLabelTable', side_effect =mocked_addImageToLabelTable)
    def test_labelOnS3Upload(self, mocked_getLabelFromRekognition, mocked_addImageToLabelTable):
        dummyContext = {}
        response = labelOnS3Upload(self.S3_event_mock_valid(), dummyContext)

        expected_response = {
            "statusCode": 200,
            "body": "{\"addImageToLabelTableResponse\": {\"statusCode\": 200, \"body\": \"{\\\"filename\\\": \\\"album1/images.jpg\\\", \\\"labels\\\": [\\\"furniture 99.89%\\\", \\\"chair 99.00%\\\", \\\"dining table 98.89%\\\", \\\"table 97.89%\\\", \\\"wood 96.89%\\\"]}\"}}"
        }

        self.assertEqual(mocked_getLabelFromRekognition.call_count, 1)
        self.assertEqual(mocked_addImageToLabelTable.call_count, 1)
        self.assertEqual(response, expected_response)

    # Mock S3 Upload
    def S3_event_mock_valid(self):
        return {
            "Records": [
                {
                "s3": {
                    "bucket": {
                    "name": "imagelabeller-ssem-2022-sij"
                    },
                    "object": {
                    "key": "album1/images.jpg"
                    }
                }
                }
            ]
        }