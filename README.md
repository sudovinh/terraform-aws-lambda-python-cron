# terraform-aws-lambda-python-cron
A module that package your python code and dependencies together then run on a scheduled time via cloudwatch.

This repo layout was inspired by [Cloud Possee](https://github.com/cloudposse). Go check them out for cool terraform modules.

## Usage

**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/sudovinh/terraform-aws-lambda-python-cron/releases).

For a complete example, see [examples](examples/).

```hcl
module "python_lambda" {
  source               = "https://github.com/sudovinh/terraform-aws-lambda-python-cron.git?ref=master"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.subnet_ids
  function_name        = "test"
  function_description = "This is a test"
  function_mem_size    = 128
  function_timeout     = 300
  source_code_path     = "{path to Python source code}/python_script.py"
  script_name          = "python_script.py"
  python_version       = "3.7
  cron_schedule        = "rate(5 minutes)"
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
