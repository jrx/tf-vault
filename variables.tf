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
  type        = list(any)
  description = "List of the availability zones to use."
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "amis" {
  type = map(string)
  default = {
    # eu-central-1 = "ami-337be65c" # centos 7
    # eu-north-1 = "ami-026f0eb2e8006617d" # centos 7
    # eu-north-1 = "ami-059464b63014a9d6a" # rocky linux 8
    eu-north-1 = "ami-07c0f40b66e9893c4" # rocky linux 9
  }
}

variable "instance_username" {
  default = "rocky"
}

variable "num_vault" {
  description = "Specify the amount of Vault servers. For redundancy you should have at least 3."
  default     = 1
}

variable "vault_version" {
  default     = "1.6.3"
  description = "Specifies which Vault version instruction to use."
}

variable "vault_instance_type" {
  description = "Vault server instance type."
  default     = "t3.small"
}

variable "vault_license" {
  default     = ""
  description = "Vault license string."
}

variable "vault_shared_san" {
  type        = string
  description = "This is a shared server name that the certs for all Vault nodes contain. This is the same value you will supply as input to the Vault installation module for the leader_tls_servername variable."
  default     = "vault"
}