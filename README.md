# terraform-aws-lambda-python-cron
A module that package your python code and dependencies together then run on a scheduled time via cloudwatch.

## Usage

**IMPORTANT:** 
If your scripts requires variables, [this](https://github.com/sudovinh/terraform-aws-lambda-python-cron/blob/f29cf1b695debc086868c92e6879c49b2b91c0f0/main.tf#L132-L137) must be uncommentted and edited. There must be a variable block for each variable in variables.tf

ex.
```hcl
# script requires MASTER_PASSWORD .
environment {
  variables = {
    MASTER_PASSWORD = var.master_password 
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 2.0 |
| null | ~> 2.0 |
| template | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | This module will not create any resources unless enabled is set to "true" | `bool` | `true` | no |
| cron_schedule | CloudWatch Events rule schedule using cron or rate expression | `string` | n/a | yes |
| function_name | Function Name | `string` | n/a | yes |
| function_description | Description for Lambda Function | `string` | n/a | yes |
| function_mem_size | Lambda Function allocated memory size 128MB to 3008MB [AWS Limit](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html)| `number` | n/a | yes |
| function_timeout | Lambda Function timeout 1 second to 900 seconds. [AWS Limit](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html) | `number` | n/a | yes |
| source_code_path | Where your Python script lives | `string` | n/a | yes |
| script_name | Python script name | `string` | n/a | yes |
| python\_version | The Python version to use | `string` | `"3.7"` | yes |
| subnet\_ids | Subnet IDs | `list(string)` | n/a | yes |
| function_timeout| Timeout for Lambda function in seconds | `number` | `300` | no |
| vpc\_id | The VPC ID for the Lambda function | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda\_function\_arn | ARN of the Lambda Function |
| security\_group\_id | Security Group ID of the Lambda Function |
