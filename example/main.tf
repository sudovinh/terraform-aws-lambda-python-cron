# Setup AWS provider
provider "aws" {
  region              = var.main_region
}

# Save Terraform State to S3 / optional
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = var.terraform_state_s3
    dynamodb_table = var.terraform_state_db_table
    region         = var.terraform_state_s3_region
    key            = var.terraform_key
    role_arn       = var.terraform_state_role_arn
  }
}

# Using Cloud Posse modules
module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.10.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.19.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false
}

module "python_lambda" {
  source               = "https://github.com/sudovinh/terraform-aws-lambda-python-cron.git?ref=master"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.subnet_ids
  function_name        = "url_response"
  function_description = "Print reponse text"
  function_mem_size    = 128
  function_timeout     = 300
  source_code_path     = "${path.cwd}"
  script_name          = "print_response.py"
  python_version       = "3.7"
  cron_schedule        = "rate(5 minutes)"
}