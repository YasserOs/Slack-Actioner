resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
  
  availability_zone = "us-east-2a"
}

resource "aws_default_subnet" "default_subnet_b" {
  
  availability_zone = "us-east-2b"
}


