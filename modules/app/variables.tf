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

variable "public_subnet_data" {
  type = object({
    id   = string
    cidr = string
  })
  description = "public subnet data (id & cidr) where public instance will locate"
}

variable "private_subnets_data" {
  type = list(object({
    id   = string
    cidr = string
  }))
  description = "private subnets data (id & cidr)"
}
