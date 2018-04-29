
## Introduction
Terraform module to set up:
 - Static website on AWS S3
 - Publish website via AWS Cloudfront for https support, decreased latency, full page caching, IPv6 support, Ddos protection
 - Create AWS Route53 record for website (optional)
 - Deploy website content - upload your document root to S3 bucket. 

## Usage

### Preconditions
1. Create a hosted zone in AWS Route 53 for your domain. The hosted zone should be in use for the domain.
1. Generate Access key and Access token for your AWS User
1. Install `terraform`

### Include it as a module from github

Create file index.tf with your configuration:
```

provider "aws" {
  version = "~> 1.12"
  // Region "us-east-1" will establish Cloudfront <==> S3 integration faster
  region = "us-east-1"
  access_key = "XXXXXX"
  secret_key = "XXXXXXXXXXX"
}
provider "archive" {
  version = "~> 1.0"
}

module "static_website_autosync_terraform" {
  source       = "github.com/maxmode/static_website_autosync_terraform"

  // Website configuration.
  // Changes in these parameters will take 5..30min due to required update of Cloudfront distribution.
  domain = "example.com" // Website domain name. Both subdomains and apex domains supported.
  certificate_arn = "arn:aws:acm:us-east-1:???"
  cache_ttl = "60" // In seconds. For how long to cache content in Cloudfront.

  // AWS Route53 Alias record.
  enabled = "0" // 1 - Create record; 0 - do not create/remove record. Can be used to enable/disable website.
  route53_zone_id = "Z1XXXXXXX" // AWS Route53 Hosted zone ID for your domain

  // All files form this folder will be uploaded to your static websites.
  // Updates in files will be also synchonized.
  document_root = "../../../websites/XXX" // Relative path from this file
}


```

### Execute terraform
 
 - Run `terraform init`
 - Run `terraform apply`
 - Wait 5..30 min, until Cloudfront synchronizes configuration across all endpoints

### How to check?

Go to website https://example.com , your local document root should be hosted there

## Credits

Based on github repositories: 
 - https://github.com/ahupp/python-magic
 - https://github.com/carloscarcamo/aws-lambda-unzip-py
