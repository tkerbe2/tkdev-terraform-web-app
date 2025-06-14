#                     _    __ 
#                    | |  / _|
#  __   ___ __   ___ | |_| |_ 
#  \ \ / / '_ \ / __|| __|  _|
#   \ V /| |_) | (__ | |_| |  
#    \_/ | .__/ \___(_)__|_|  
#        | |                  
#        |_|                  

#===================#
# Main VPC Resource #
#===================#

resource "aws_vpc" "main_vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = "true"
  enable_dns_hostnames  = "true"
  instance_tenancy      = "default"


  tags = {
    Name = "${local.name_prefix}-vpc"
    Environment = var.env
  }
}

#=============================#
# Internet Gateway Resource   #
#=============================#

resource "aws_internet_gateway" "main_igw" {

  vpc_id   = aws_vpc.main_vpc.id
  
depends_on = [aws_vpc.main_vpc]

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}


#==================#
# Subnet Resources #
#==================#

#=========#
# Subnets #
#=========#

resource "aws_route_table_association" "rt_a" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.app_sn[count.index].id
  route_table_id = aws_default_route_table.default_rt.id
}

resource "aws_subnet" "app_sn" {

  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.borrowed_bits, count.index)
  depends_on              = [aws_vpc.main_vpc]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-${count.index}-web"
  }

}