# ---
# VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "${var.vpc_cidr_block}"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    tags                 = merge(local.default_tags, map("Name","eks-vpc"))
}

# ---
# Subnet
resource "aws_subnet" "sn" {
    count                   = var.num_subnets
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
    availability_zone       = element(data.aws_availability_zones.available.names, count.index % var.num_subnets)
    tags   = merge(local.default_tags, map("Name","eks-sn"))
}

# ---
# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags   = merge(local.default_tags, map("Name","eks-igw"))
}

# ---
# Route Table
resource "aws_route_table" "rt" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = merge(local.default_tags, map("Name","eks-rt"))
}

resource "aws_route_table_association" "rta" {
    count          = var.num_subnets
    subnet_id      = element(aws_subnet.sn.*.id, count.index)
    route_table_id = aws_route_table.rt.id
}

# ---
# Security Group
resource "aws_security_group" "eks-master" {
    name        = "eks-master-sg"
    description = "EKS master security group"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(local.default_tags, map("Name","eks-master-sg"))
}

resource "aws_security_group" "eks-node" {
    name        = "eks-node-sg"
    description = "EKS node security group"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description     = "Allow cluster master to access cluster node"
        from_port       = 1025
        to_port         = 65535
        protocol        = "tcp"
        security_groups = [aws_security_group.eks-master.id]
    }

    ingress {
        description     = "Allow cluster master to access cluster node"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [aws_security_group.eks-master.id]
        self            = false
    }

    ingress {
        description = "Allow inter pods communication"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self        = true
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags   = merge(local.default_tags, map("Name","eks-node-sg"))
}