variable "enabled" {
  description = "This module will not create any resources unless enabled is set to "true""
}
variable "vpc_id" {
  description = "VPC ID"
}
variable "subnet_ids" {
  description = "List of subnets"
}
variable "function_name" {
  description = "Lambda function name"
}
variable "function_description" {
  description = "Function description"
}
variable "function_mem_size" {
  description = "Function memory size"
}
variable "function_timeout" {
  description = "Function max timeout in seconds, AWS max limit=15 min"
}
variable "source_code_path" {
  description = "Where your python script source code lives"
}
variable "script_name" {
  description = "Python script name"
}
variable "python_version" {
  description = "Python Runtime Version. ex.3.7"
  default = "3.7"
}
variable "cron_schedule" {
  description = "CloudWatch Events rule schedule using cron or rate expression"
}
