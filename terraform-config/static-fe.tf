# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = var.website_bucket_name
  acl    = "public-read"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Website"
    Environment = "production"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "HEAD", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.website_bucket_name}/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "./html/index.html"
  etag         = filemd5("./html/index.html")
  content_type = "text/html"

}

resource "aws_s3_bucket_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  source       = "./html/error.html"
  etag         = filemd5("./html/error.html")
  content_type = "text/html"

}

resource "aws_s3_bucket_object" "js" {
  bucket = aws_s3_bucket.website.id
  key    = "s3_photoExample.js"
  source = "./html/s3_photoExample.js"
  etag   = filemd5("./html/s3_photoExample.js")

}

resource "aws_s3_bucket_object" "config" {
  bucket = aws_s3_bucket.website.id
  key    = "config.js"
  source = "./html/config.js"
  etag   = filemd5("./html/config.js")

}

resource "aws_s3_bucket_object" "fontcss" {
  bucket = aws_s3_bucket.website.id
  key    = "css/font.css"
  source = "./html/css/font.css"
  etag   = filemd5("./html/css/font.css")
}

resource "aws_s3_bucket_object" "maincss" {
  bucket = aws_s3_bucket.website.id
  key    = "css/main.css"
  source = "./html/css/main.css"
  etag   = filemd5("./html/css/main.css")
}

resource "aws_s3_bucket_object" "fontn4" {
  bucket = aws_s3_bucket.website.id
  key    = "fonts/fairplex-wide-n4.woff"
  source = "./html/fonts/fairplex-wide-n4.woff"
  etag   = filemd5("./html/fonts/fairplex-wide-n4.woff")
}

resource "aws_s3_bucket_object" "fontn7" {
  bucket = aws_s3_bucket.website.id
  key    = "fonts/fairplex-wide-n7.woff"
  source = "./html/fonts/fairplex-wide-n7.woff"
  etag   = filemd5("./html/fonts/fairplex-wide-n7.woff")
}

resource "aws_s3_bucket_object" "albumFolder" {
  bucket = aws_s3_bucket.website.id
  key    = "album1/"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}