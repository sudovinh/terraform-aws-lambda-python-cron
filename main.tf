# IAM
#--------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "lambda_iam_policy" {
  count            = var.enabled ? 1 : 0
  name        = "${var.function_name}-iam-policy"
  path        = "/"
  description = "Policy for ${var.function_name} lambda execution role"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "sid": "LambdaLogCreation",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": ["*"]
    },
    {
      "sid": "LambdaVPCconfig",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": ["*"]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = join("", aws_iam_role.lambda_role.*.name)
  policy_arn = join("", aws_iam_role.lambda_role.*.arn)
}

resource "aws_iam_role_policy_attachment" "policy_attachment_vpc" {
  count      = 1
  role       = join("", aws_iam_role.lambda_role.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Security Group
#--------------------------------------------------------------
resource "aws_security_group" "lambda_sg" {
  count       = var.enabled ? 1 : 0
  name        = "${var.function_name}-lambda-sg"
  description = var.function_description
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "all_egress_from_lambda" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all out-going traffic from Lambda"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.lambda_sg.*.id)
}

# Packaging the script and dependencies
#--------------------------------------------------------------
resource "null_resource" "install_python_dependencies" {
  triggers = {
    main         = "${base64sha256(file("${var.source_code_path}/${var.script_name}"))}"
    requirements = "${base64sha256(file("${var.source_code_path}/requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/helper_scripts/python_builder.sh"
    
    environment = {
      source_code_path = var.source_code_path
      script_name = var.script_name
      path_cwd         = path.cwd
      runtime          = "python${var.python_version}"
      function_name    = var.function_name
      package_name     = var.function_name
    }
  }
}

data "archive_file" "zip_script" {
  count       = var.enabled ? 1 : 0
  type        = "zip"
  source_dir = "${path.cwd}/lambda_final_package_script"
  output_path = "${path.cwd}/${var.function_name}.zip"
  depends_on = [null_resource.install_python_dependencies]
}

# Main Lambda function
#--------------------------------------------------------------
resource "aws_lambda_function" "lambda_function" {
  count            = var.enabled ? 1 : 0
  filename         = data.archive_file.zip_script.output_path
  function_name    = var.function_name
  description      = var.function_description
  memory_size      = var.function_mem_size
  timeout          = var.function_timeout
  runtime          = "python${var.python_version}"
  role             = join("", aws_iam_role.lambda_role.*.arn)
  handler          = "${var.function_name}.${var.function_handler}"
  source_code_hash = data.archive_file.zip_script.output_base64sha256

  # environment {
  #   variables = {
  #     url = var.url (needs to be in your variables.tf as well)
  #     {"Your Python Script Environment variables goes here"}
  #   }
  # }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [join("", aws_security_group.lambda_sg.*.id)]
  }
}

# Cloudwatch for cron schedule
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "cloudwatch_schedule" {
  count            = var.enabled ? 1 : 0
  name                = "${var.function_name}-schedule"
  description         = "${var.function_name} execution schedule"
  schedule_expression = var.cron_schedule
}

resource "aws_cloudwatch_event_target" "event_target" {
  count            = var.enabled ? 1 : 0
  target_id = "${var.function_name}-event-target"
  rule      = join("", aws_cloudwatch_event_rule.cloudwatch_schedule.*.name)
  arn       = join("", aws_lambda_function.lambda_function.*.arn)
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count            = var.enabled ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = join("", aws_lambda_function.lambda_function.*.arn)
  principal     = "events.amazonaws.com"
  source_arn    = join("", aws_cloudwatch_event_rule.cloudwatch_schedule.*.arn)
}
