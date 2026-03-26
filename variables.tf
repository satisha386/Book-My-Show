variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "bms-key"
}

variable "public_key_path" {
  description = "Path to your local SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Ubuntu 24.04 LTS in us-east-1 — update if using a different region
variable "ubuntu_ami" {
  description = "Ubuntu 24.04 LTS AMI ID"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}
