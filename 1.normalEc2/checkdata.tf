# provider "aws" {
#   region = "us-east-1"
# }

# Data source to retrieve all security groups
data "aws_security_groups" "all" {}

# Output the IDs of all security groups
output "all_security_group_ids" {
  value = data.aws_security_groups.all.ids
}


