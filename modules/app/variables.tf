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

variable "public_subnet_id" {
  type        = string
  description = "public subnet id where public instance will locate"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnet ids where private instance will locate"
}
