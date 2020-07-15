variable "main_region" {
  description = "Main AWS Region"
  default = "us-west-1"
}
variable "terraform_state_s3" {
  description = "S3 bucket to save your terraform state. Optional"
}
variable "terraform_state_db_table" {
  description = "DynamboDB table for terraform state. Optional"
}
variable "terraform_state_s3_region" {
  description = "Region of your S3 bucket for that terraform state. Optional"
}
variable "terraform_key" {
  description = "terraform state file name. Optional"
}
variable "terraform_state_role_arn" {
  description = "AWS role to save your terraform state. Optional"
}
