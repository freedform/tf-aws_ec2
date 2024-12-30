variable "create_ec2" {
  description = "Controls EC2 creation"
  type        = bool
  default     = true
}

variable "instance_count" {
  description = "How many instances to be created"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "VPC subnets to allocation instance in"
  type        = list(string)
}

variable "public_ip" {
  description = "Assign public ip address"
  type        = bool
  default     = false
}

variable "iam_role" {
  description = "IAM role"
  type        = string
  default     = null
}

variable "key_name" {
  description = "AWS Key pair value"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of security groups"
  type        = list(string)
  default     = null
}

variable "hostname" {
  description = "Set an instance hostname, otherwise instance ID is used"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "If true any change of user data will cause instance recreation"
  type        = bool
  default     = false
}

variable "user_data_check" {
  description = "Check user data execution"
  type        = bool
  default     = false
}

variable "user_data_check_username" {
  description = "Username to check user data execution"
  type        = string
  default     = null
}

variable "user_data_check_password" {
  description = "Password to check user data execution"
  type        = string
  default     = null
}

variable "user_data_check_private_key" {
  description = "Private key to check user data execution"
  type        = string
  default     = null
}

variable "user_data_check_connection_type" {
  description = "Connection type to check user data execution"
  type        = string
  default     = "ssh"
}

variable "user_data_check_ip" {
  description = "Private/public ip address to connect to check user data execution"
  type        = string
  default     = "private"
}

variable "user_data_check_timeout" {
  description = "Timeout in seconds to wait for user data finish"
  type        = number
  default     = 300
}

variable "ami" {
  description = "EC2 AMI"
  type        = string
}

variable "type" {
  description = "EC2 instance type"
  type        = string
}

variable "tags" {
  description = "Tags to be assigned to instance"
  type        = object({})
  default     = {}
}

variable "check_internet_connectivity" {
  description = "Check internet connectivity in user-data script"
  type        = bool
  default     = true
}