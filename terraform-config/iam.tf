resource "aws_iam_role" "lambda-exec-upload" {
  name = "image-upload-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda-exec-label" {
  name = "image-labeller-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


resource "aws_iam_policy" "lambda-upload-cw-policy" {
  name        = "Lambda-cw-upload-policy"
  description = "Lambda-cw-upload-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.Imagehandler-lambda-upload-LogGroup.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda-upload-dynamodb-policy" {
  name        = "Lambda-upload-dynamodb-policy"
  description = "Lambda-upload-dynamodb-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "GetStreamRecords",
        "Effect" : "Allow",
        "Action" : "dynamodb:GetRecords",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rekognition:CompareFaces",
          "rekognition:DetectFaces",
          "rekognition:DetectLabels",
          "rekognition:ListCollections",
          "rekognition:ListFaces",
          "rekognition:SearchFaces",
          "rekognition:SearchFacesByImage",
          "rekognition:DetectText",
          "rekognition:GetCelebrityInfo",
          "rekognition:RecognizeCelebrities",
          "rekognition:DetectModerationLabels",
          "rekognition:GetLabelDetection",
          "rekognition:GetFaceDetection",
          "rekognition:GetContentModeration",
          "rekognition:GetPersonTracking",
          "rekognition:GetCelebrityRecognition",
          "rekognition:GetFaceSearch",
          "rekognition:GetTextDetection",
          "rekognition:GetSegmentDetection",
          "rekognition:DescribeStreamProcessor",
          "rekognition:ListStreamProcessors",
          "rekognition:DescribeProjects",
          "rekognition:DescribeProjectVersions",
          "rekognition:DetectCustomLabels",
          "rekognition:DetectProtectiveEquipment",
          "rekognition:ListTagsForResource",
          "rekognition:ListDatasetEntries",
          "rekognition:ListDatasetLabels",
          "rekognition:DescribeDataset"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-upload-cw-attach" {
  role       = aws_iam_role.lambda-exec-upload.name
  policy_arn = aws_iam_policy.lambda-upload-cw-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-upload-dynamodb-attach" {
  role       = aws_iam_role.lambda-exec-upload.name
  policy_arn = aws_iam_policy.lambda-upload-dynamodb-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-label-cw-attach" {
  role       = aws_iam_role.lambda-exec-label.name
  policy_arn = aws_iam_policy.lambda-upload-cw-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda-label-dynamodb-attach" {
  role       = aws_iam_role.lambda-exec-label.name
  policy_arn = aws_iam_policy.lambda-upload-dynamodb-policy.arn
}