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
  type = object({
    cidr = string
    az   = string
  })
  description = "public subnet cidr blocks and az"
  validation {
    condition = length(var.public_subnet_data) >= 1
    error_message = "at least one public subnet"
  }
}

variable "private_subnet_data" {
  type = list(object({
    cidr = string
    az   = string
  }))
  description = "private subnet cidr blocks and az"
}