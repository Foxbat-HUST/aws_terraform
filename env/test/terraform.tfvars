region = "ap-northeast-1"
tags = {
  env        = "test"
  created_by = "terraform"
}

cidr_block = "192.168.0.0/16"


subnets_data = [{
    az           = "ap-northeast-1a"
    public_cidr  = "192.168.1.0/24"
    private_cidr = "192.168.2.0/24"
    }, {
    az           = "ap-northeast-1c"
    public_cidr  = "192.168.3.0/24"
    private_cidr = "192.168.4.0/24"
  }]
public_subnet_data = {
  cidr = "192.168.1.0/24"
  az   = "ap-northeast-1a"
}

private_subnet_data = [
  {
    cidr = "192.168.3.0/24"
    az   = "ap-northeast-1a"
  },
  {
    cidr = "192.168.4.0/24"
    az   = "ap-northeast-1c"
  }
]

instance_spec = {
  ami  = "ami-0d979355d03fa2522"
  type = "t2.micro"
}

ssh_key = {
  file_path = "your ssh public key"
  name      = "ssh key"
}
