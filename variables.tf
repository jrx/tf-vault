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
  default = "eu-central-1"
}

variable "aws_azs" {
  type        = list
  description = "List of the availability zones to use."
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "amis" {
  type = map(string)
  default = {
    eu-central-1 = "ami-337be65c" # centos 7
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
  default     = "1.5.4"
  description = "Specifies which Vault version instruction to use."
}

variable "vault_instance_type" {
  description = "Vault server instance type."
  default     = "t2.micro"
}