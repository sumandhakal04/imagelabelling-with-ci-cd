import re
import unittest
from unittest import mock

from getImagesByLabelHandler import getImagesByLabel

def mocked_getImageLabelsFromDB(requestFilename):
    if requestFilename == 'album1/IMG_1604.jpg':
        return {
            'Item': {
                'filename': 'album1/IMG_1604.jpg', 
                'labels': ['furniture', 'chair', 'dining table', 'table', 'wood']
            }
        }
    else:
        return {}

class test_getImagesByLabelHandler(unittest.TestCase):

    @mock.patch('getImagesByLabelHandler.getImageLabelsFromDB', side_effect =mocked_getImageLabelsFromDB)
    def test_getImagesByLabel_valid(self, mocked_getImageLabelsFromDB):
        dummyContext = {}
        response = getImagesByLabel(self.api_event_mock_valid(), dummyContext)

        expected_response = {
            'statusCode': 200, 
            'body': '[{"filename": "album1/IMG_1604.jpg", "labels": ["furniture", "chair", "dining table", "table", "wood"]}]'
            }

        self.assertEqual(mocked_getImageLabelsFromDB.call_count, 1)
        self.assertEqual(response, expected_response)

    @mock.patch('getImagesByLabelHandler.getImageLabelsFromDB', side_effect =mocked_getImageLabelsFromDB)
    def test_getImagesByLabel_invalid(self, mocked_getImageLabelsFromDB):
        dummyContext = {}
        response = getImagesByLabel(self.api_event_mock_invalid(), dummyContext)

        expected_response = {
            'statusCode': 200, 
            'body': '[]'
            }

        self.assertEqual(mocked_getImageLabelsFromDB.call_count, 1)
        self.assertEqual(response, expected_response)

    # Mock api call event
    def api_event_mock_valid(self):
        return {
            "Records": [
            {
                "awsRegion": "eu-central-1",
                "label": "furniture",
                "s3": {
                    "bucket": {
                        "name": "imagelabeller-ssem-2022-sij"
                    },
                    "object": {
                        "key": "album1/IMG_1604.jpg"
                    }
                }
            }
            ]
        }
        
    def api_event_mock_invalid(self):
        return {
            "Records": [
            {
                "awsRegion": "eu-central-1",
                "label": "furniture",
                "s3": {
                    "bucket": {
                        "name": "imagelabeller-ssem-2022-sij"
                    },
                    "object": {
                        "key": "invalid"
                    }
                }
            }
            ]
        }