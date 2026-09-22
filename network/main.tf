#provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ashfall-terraform-state"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ashfall-terraform-locks"
    encrypt        = true
    profile        = "ashfall"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "ashfall"
}


#end of provider block

#VPC and Subnets resources. 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ashfall-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ashfall-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ashfall-public-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "ashfall-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ashfall-private-b"
  }
}

resource "aws_internet_gateway" "ashfall_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ashfall-igw"
  }
}

# Route table and it's subnet associations.
resource "aws_route_table" "ashfall_public_rt" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ashfall_igw.id
  }

  tags = {
    Name = "ashfall_public_rt"
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.ashfall_public_rt.id 
}
resource "aws_route_table_association" "public_b_assoc" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.ashfall_public_rt.id 

}  
