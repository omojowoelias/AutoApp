# Configure the AWS Provider
provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
            Name        = "${var.project_name}-${var.environment}"
            Environment = var.environment
            Project     = var.project_name
        }
    }   
}