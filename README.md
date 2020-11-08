# Deploy API Gateway, Lambda and DynamoDB using Terraform

Objective of this project is to create a serverless application with AWS services like API Gateway, Lambda and DynamoDB and deploying them using Terraform. The lambda function will have both read and write access to the DynamoDB table. Depending on the API call request body, the lambda will perform either read or write operation on the DynamoDB table.
