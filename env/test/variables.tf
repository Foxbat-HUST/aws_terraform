variable "region" {
  type        = string
  description = "region"
}

variable "cidr_block" {
  description = "vpc cidr block"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "common tag"
}

variable "subnets_data" {
  type = list(object({
    az           = string
    private_cidr = string
    public_cidr  = string
  }))

  description = "private and public subnet for individual az"
  validation {
    condition     = length(var.subnets_data) > 0
    error_message = "subnet(s) data must be provided"
  }

}

variable "public_subnet_data" {
  description = "public subject data (az and cird block)"
  type = object({
    cidr = string
    az   = string
  })
}

variable "private_subnet_data" {
  description = "private subject data (az and cird block)"
  type = list(object({
    cidr = string
    az   = string
  }))
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
