provider "aws" {
   region = "us-east-1"
}

resource "aws_dynamodb_table" "ddbtable" {
  name             = "myDB"
  hash_key         = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.role_for_LDC.id

  policy = file("policy.json")
}


resource "aws_iam_role" "role_for_LDC" {
  name = "myrole"
  
  assume_role_policy = file("assume_role_policy.json")

}


resource "aws_lambda_function" "myLambda" {

  function_name = "myfunc"
  s3_bucket     = "mybuck7086125"
  s3_key        = "terraLambda.zip"
  role          = aws_iam_role.role_for_LDC.arn
  handler       = "terraLambda.handler"
  runtime       = "nodejs12.x"
}


resource "aws_api_gateway_rest_api" "apiLambda" {
  name        = "myAPI"

}


  resource "aws_api_gateway_resource" "Resource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "myresource"

}


resource "aws_api_gateway_method" "Method" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.Resource.id
   http_method   = "POST"
   authorization = "NONE"
}


resource "aws_api_gateway_integration" "lambdaInt" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.Resource.id
   http_method = aws_api_gateway_method.Method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.myLambda.invoke_arn
   
}


resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [aws_api_gateway_integration.lambdaInt]

   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   stage_name  = "Prod"
}


resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.myLambda.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/Prod/POST/myresource"

}


output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}