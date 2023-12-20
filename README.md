# Cloud_Programming_Project
Hosting a static website using Terraform

This cloud architecture contains 
  a S3 bucket
  two simple html-files as website and error page
  a CloudFront distribution

To use it:
1. Make sure AWS and Terraform are installed
2. Configure AWS on your machine, entering the access key using the AWS CLI (it is recommended not to hardcode the credentials in the terraform files since these are sensitive information)
3. Download the files and place them in a directory
4. Run: terraform init
5. Run: terraform plan
6. Run: terraform apply

