output "website-endpoint" {
  value = aws_s3_bucket.website.website_endpoint
}

output "APIInvokeURL" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "IdentityPoolId" {
  value = aws_cognito_identity_pool.s3.id
}