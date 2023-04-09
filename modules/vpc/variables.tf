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
