region = "ap-northeast-1"
tags = {
  author = "anpq"
  tool   = "terraform"
}
cidr_block = "192.168.0.0/16"
ec2_data = {
  ami           = "ami-0d979355d03fa2522"
  instance_type = "t2.micro"
}

public_subnet_data = [
  {
    cidr = "192.168.1.0/24"
    az   = "ap-northeast-1a"
  },
  {
    cidr = "192.168.2.0/24"
    az   = "ap-northeast-1c"
  }
]

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