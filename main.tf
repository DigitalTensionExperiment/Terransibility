
# [SECURITY]
# IAM : security should be at the top of any infrastructure plan
# S3_access







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








