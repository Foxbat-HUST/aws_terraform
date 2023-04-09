variable "region" {
  type        = string
  description = "vpc region"
}

variable "tags" {
  type        = map(string)
  description = "common tag"
}

variable "instance_spec" {
  type = object({
    ami  = string
    type = string
  })

  description = "ec2 spec (ami, instance type)"
}

variable "ssh_key" {
  type = object({
    name      = string
    file_path = string
  })

  description = "ssh key"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "public_subnets_data" {
   type = list(object({
    id   = string
    cidr = string
  }))
  description = "public subnets data (id & cidr)"
  validation {
    condition = length(var.public_subnets_data) > 0
    error_message = "public subnets data must be provided"
  }
}

variable "private_subnets_data" {
  type = list(object({
    id   = string
    cidr = string
  }))
  description = "private subnets data (id & cidr)"
}
