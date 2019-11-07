
data "aws_availability_zones" "available" {}

provider "aws" {
    region = "us-east-2"
  
}

terraform {
    backend "s3" {
        bucket = "demo-akorolchuk-terraform-state"
        key = "dev/network/terraform.tfstate"
        region = "us-east-2"
    }
}

variable "vpc_cidr" {
    default ="10.0.0.0/16"
  
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

resource "aws_subnet" "main" {
  count                   = length(var.public_subnet_cidrs)
  #Елемнт принимает два параметр лист и индекс листа в count.index добавляем индекс
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  vpc_id     = "${aws_vpc.main.id}"
#   cidr_block = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
#   availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "Main"
  }
}



resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "My VPC"
    }
  
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
  
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

# output "subnet_id" {
#   value = aws_subnet.main.id
# }

output "public_subnet_ids" {
  value = aws_subnet.main[*].id
}


