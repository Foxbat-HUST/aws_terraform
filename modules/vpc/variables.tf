variable "region" {
  type        = string
  description = "vpc region"
}

variable "cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "tags" {
  type        = map(string)
  description = "tags list"
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