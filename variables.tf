variable "cluster_name" {
  description = "Name of the cluster."
  default     = "hashi-example"
}

variable "owner" {
  description = "Owner tag on all resources."
  default     = "myuser"
}

variable "key_name" {
  description = "Specify the AWS ssh key to use."
}

variable "private_key" {
  description = "SSH private key to provision the cluster instances."
}

variable "aws_region" {
  default = "eu-north-1"
}

variable "aws_azs" {
  type        = list
  description = "List of the availability zones to use."
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "amis" {
  type = map(string)
  default = {
    # eu-central-1 = "ami-337be65c" # centos 7
    eu-north-1 = "ami-026f0eb2e8006617d" # centos 7
  }
}

variable "instance_username" {
  default = "centos"
}

variable "num_vault" {
  description = "Specify the amount of Vault servers. For redundancy you should have at least 3."
  default     = 3
}

variable "vault_version" {
  default     = "1.6.0-rc"
  description = "Specifies which Vault version instruction to use."
}

variable "vault_instance_type" {
  description = "Vault server instance type."
  default     = "t3.micro"
}