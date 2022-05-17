resource "aws_vpc" "vpc_for_aurora" {
    cidr_block           = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    tags                 = merge(local.default_tags, tomap({Name = "aurora-vpc"}))
}

# ---
# Subnet
resource "aws_subnet" "pri_sn_for_aurora" {
    count                   = var.num_subnets
    vpc_id                  = aws_vpc.vpc_for_aurora.id
    cidr_block              = cidrsubnet("10.1.0.0/16", 8, count.index)
    availability_zone       = element(data.aws_availability_zones.available.names, count.index)
    tags   = merge(local.default_tags, tomap({Name = "aurora-pri_sn"}))
}