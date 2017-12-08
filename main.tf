
# [SECURITY]
# IAM : security should be at the top of any infrastructure plan
# S3_access



# [NETWORKING]

# VPC : networking will be largest section of this terraform script ;
# backbone of any instructure we decide to build
resource "aws_vpc" "vpc_name" {
  cidr_block = "10.1.0.0/16"
}
# A /16 cidr block means the fist two octets (10 and 1), are static
# the subnets will further divide this range into /24 subnets (252 addresses) ;

# If we want (ie) a max autoscaling group instance count of 300 hosts + an availability zone
# this scheme needs to be redefined;



# internet gateway
resource "aws_internet_gateway" "internet_gatways_name" {
  vpc_id = "${aws_vpc.vpc_name.id}"
}
# attach gateway to vpc_id
# prior to vpc_id being created, it's reference through interpolation syntax (see above)
## the id of any resource is the name of the resource, specified by the resource type ;


# public route table (will be conntected to the internet gateway)
# use aws_route_table resource, give it an id of "public"
resource "aws_route_table" "public" {
  # then give it a vpc_id
  vpc_id = "${aws_vpc.vpc_name.id}"
  route {
    # give it a route to the open internet...
    cidr_block = "0.0.0.0/0"
    # ...using the gateway id referenced above
    gateway_id = "${aws_internet_gateway.internet_gatways_name.id}"
  }
  # then tag it with name "public" (optional but useful for scaling)
  # could also add env tag: development, staging, production, etc;
  tags {
    Name = "public"
    Env = "development"
  }
}



# private route table
resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.vpc_name.default_route_table_id}"
  tags {
    Name = "private"
  }
}



# subnets (there will be several)
# public subnet
resource "aws_subnet" "public" {
  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1"
  tags {
    Name = "public"
  }
}
## explicit assign subnets and availability zones for every resource that needs one
## to have complete control over what we're doing
## This allows to troubleshoot quickly, based on IP and availability zones


# private subnet 1 : for one group of ASG launch servers
resource "aws_subnet" "private1" {
  cidr_block = "10.1.2.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1"
  tags {
    Name = "private1"
  }
}


# private subnet 2 : for another group of ASG servers, keeping them fault tolerant and resilient
resource "aws_subnet" "private2" {
  cidr_block = "10.1.3.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags {
    Name = "private2"
  }
}

# create s3 VPC endpoint
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = ["${aws_vpc.vpc_name.main_route_table_id}", "${aws_route_table.public.id}"]
  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*",

      "Sid": "",
    }
  ]
}
POLICY
}


### Then there are 3 RDS subnet groups:
# RDS1
resource "aws_subnet" "rds1" {
  cidr_block = "10.1.4.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags {
    Name = "rds1"
  }
}

# RDS2
resource "aws_subnet" "rds2" {
  cidr_block = "10.1.5.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1c"
  tags {
    Name = "rds2"
  }
}

# RDS3
resource "aws_subnet" "rds3" {
  cidr_block = "10.1.6.0/24"
  vpc_id = "${aws_vpc.vpc_name.id}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1d"
  tags {
    Name = "rds3"
  }
}


# Subnet associations
resource "aws_route_table_association" "public_association" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1_association" {
  subnet_id = "${aws_subnet.private1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private2_association" {
  subnet_id = "${aws_subnet.private2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Must map private subnets to public gateway
# without assigning public IP's to them

resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "rds_subnetgroup"
  subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds2.id}", "${aws_subnet.rds3.id}"]
  tags {
    Name = "rds_sng"
  }
}



# Security groups
## public : will allow access from anywhere to port 80, but only from your IP address to port 22
resource "aws_security_group" "public" {
  name = "sg_public"
  description = ""
  vpc_id = "${aws_vpc.vpc_name.id}"

  # SSH
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    # May specify security groups rather than CIDR blocks:
    cidr_blocks = ["${var.localip}"]
  }

  # HTTPS
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## private
resource "aws_security_group" "private" {
  name = "sg_private"
  description = ""
  vpc_id = "${aws_vpc.vpc_name.id}"

  # Access from other security groups
  ingress {
    from_port = 0
    protocol = ""
    to_port = 0
  }

  egress {
    from_port = 0
    protocol = ""
    to_port = 0
  }
}

## RDS Security group
resource "aws_security_group" "RDS" {
  name = "sg_rds"
  description = ""
  vpc_id = "${aws_vpc.vpc_name.id}"

  # SQL accress from public/private security group
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = ["${aws_security_group.public.id}", "${aws_security_group.private.id}"]
  }
}



# [S3 CODE BUCKET]
resource "aws_s3_bucket" "code" {
  # random string attached ensures uniqueness
  bucket = "${var.domain_name}_randomcodex56845"
  acl = ""
  force_destroy = true
  tags {
    Name = "code bucket"
  }
}


# if you want to create a cloud front distribution
# add media bucket here



# [DB & COMPUTE RESOURCES]
resource "aws_db_instance" "db" {
  # For instance, use micro to stay within the free tier:
  instance_class = "db.t2.small"

  # 100 is recommended because 100 GB gives us more IOPS (IO per second) than a lower number
  # IOPS = read and writes per second:
  allocated_storage = 100

  engine = "mysql"
  engine_version = ""
  instance_class = "${var.db_instance_class}"
  name = "${var.dbname}"
  # username to access the instance
  username = "${var.dbuser}"
  password = "${var.dbpassword}"

  # Refers to the subnet group we created earlier:
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnetgroup.name}"

  # parameter_group_name

  # setting this to true gives us high availability:
  # (2 instances will synchronize with each other)
  multi_az = false

  storage_type = "gp2" #general purpose

  backup_retention_period = 30

  availability_zone = ""

  vpc_security_group_ids = ["${aws_security_group.RDS.id}"]

  tags {
    Name = ""
  }
}


# key pair (from ssh-keygen ran locally)
resource "aws_key_pair" "auth" {
  public_key = "${}"
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}



# S3 requires more resources:
## buckets (gets created in the compute section of script)
## ability for EC2 to access buckets {profile, role policy, role in IAM section of script}
## endpoint from which private instances can access the bucket

# IAM
# S3 access
resource "aws_iam_instance_profile" "s3_access" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access.name}"
  # roles = [] appears to be depricated
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "*",

    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access" {
  name = "s3_access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "",
    }
  ]
}
EOF

}

# Check AWS docs and Terraform docs for sample policies to copy and paste


# master dev server (uses ansible playbook)
# load balancer (forwards traffic to private instances)
# AMI (from our dev instance)
# Launch configs (will use AMI from previous step to deploy instances)
# ASG (will use AMI and launch configs to create Production instances deployed in private subnet)



# [ROUTE53 RECORDS]
# primary zone (used for delegation set created earlier)
# www record (points to LB alias)
# dev record (points to dev server's public IP)
# DB (C name record that points to the RDS instance)








