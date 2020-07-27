output "lambda_security_group_id" {
  value       = join("", aws_security_group.lambda_sg.*.id)
  description = "Security Group ID of the Lambda Function"
}

output "lambda_function_arn" {
  value       = join("", aws_lambda_function.lambda_function.*.arn)
  description = "ARN of the Lambda Function"
}
