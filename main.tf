provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}



# [SECURITY]
# IAM : security should be at the top of any infrastructure plan
# S3_access


resource "aws_vpc" "vpc_name" {
  cidr_block = "10.1.0.0/16"
}
# A /16 cidr block means the fist two octets (10 and 1), are static
# the subnets will further divide this range into /24 subnets (252 addresses) ;

# If we want (ie) a max autoscaling group instance count of 300 hosts + an availability zone
# this scheme needs to be redefined;


# [NETWORKING]
#VPC : networking will be largest section of this terraform script

# internet gateway

# public route table (will be conntected to the internet gateway)
# private route table

# subnets (there will be several)
## explicit assign subnets and availability zones for every resource that needs one
## to have complete control over what we're doing
## This allows to troubleshoot quickly, based on IP and availability zones
# public subnet
# private subnet 1 : for one group of ASG launch servers
# private subnet 2 : for another group of ASG servers, keeping them fault tolerant and resilient
### Then there are 3 RDS subnet groups:
# RDS1
# RDS2
# RDS3

# Security groups
## private
## public
## RDS



# [S3 CODE BUCKET]
# if you want to create a cloud front distribution
# add media bucket here



# [COMPUTE RESOURCES]
# key pair (from ssh-keygen ran locally)
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








