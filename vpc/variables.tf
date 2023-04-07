variable "region" {
  type        = string
  description = "vpc region"
}
variable "tags" {
  type        = map(string)
  description = "tags list"
}
variable "cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "ec2_data" {
  type = object({
    ami           = string
    instance_type = string
  })
  description = "ec2 ami and type"
}

variable "public_subnet_data" {
  type = list(object({
    cidr = string
    az   = string
  }))
  description = "public subnet cidr blocks and az"
}

variable "private_subnet_data" {
  type = list(object({
    cidr = string
    az   = string
  }))
  description = "private subnet cidr blocks and az"
}

variable "enable_natgw_for_private_subnet" {
  type = bool
  description = "enable nat gateway for private subnet or not"
}

variable "ssh_key_path" {
  type        = string
  description = "absolute ssh private key location"
}