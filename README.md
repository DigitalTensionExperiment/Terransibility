# Terransibility



EC2 instances   

S3 buckets 

RDS 

roles - policies 

custom VPC - subnets 

route tables 
- private : RDS instances 
- public : <everything else> 

internet gateway (attached to elements of public route tables) 

AMI (w/ a random name) 

key pairs 

Load Balancer  

Launch configs 

user data 

Autoscaling group 
- autoscaling policies 
- availability zones 





Note: can create value maps for values needed for different env's; 






#### Core AWS features: (free tier offering) 
(see: https://aws.amazon.com/free/) 
- EC2 
- S3 
- RDS 
- DynamoDB 
- ELB 
- SNS 
- Lambda 


###### RDS  
create a subnet group 
> allow specify what subnets a DB will be in (ie: us-east-1) 

create a parameter group 
> allows to specify what parameters to change in DB settings; 
> Without shell access to a DB, this is the only way to make changes to it; 

create a security group 
> allows incoming traffic to the RDS instance; put into private subnet groups, 
 it can only be accessed by instances in the same subnet and 
 won't be accessible from the internet; 

THEN create the RDS instance 


###### S3 buckets: 
- create a bucket 
- add object [to bucket] 
- view an object 
- move an object  
- best practices 

###### EC2 buckets: 
- (...) 
- best practices 


#### Documentation types 
- getting started 
- API guide 
- dev guide 
- API reference 
- new/console user guide(s) 

#### Security and Identity 
- IAM: {users, groups, IAM access policies, roles} 

brute user has full admin rights to all parts of the account 

activate multi-factor authentication on root account 

never use root account on day-to-day basis: 
- create individual IAM users 

user groups 

permission assignments 

password policies: format and expiration rules ; 

detach policies for users so they lose access to [a resource] 

attach policy to group, and put users in group (simplified way of granting access) 

remove a user from group to remove user's access to resource 

assigning S3 policy to EC2 instances 
does not grant those instances access to S3 bucket: 
** cannot assign policies to other AWS services; 

^^ First attach a role, and then to the role attach policies ; 
Role allows service to act as a user; 




### Global infrastructure 

regions - for reducing latency; comprised of different availibility zones; 

availibility zones - isolated within a region, and house AWS resources; 
Where specific data centers are located; redundancy; 

data centers - separated regionally; 
all components of physical layer; 

S3 backs up data across multiple availability zones; 
fault tolerant architecture; 





Note: If you activate a NAT gateway and activate routes to route the traffic through the it 
instances will be able to send outgoing traffic over the NAT gateway. 
It's not possible to enable incoming traffic (e.g. webserver)




Scenario: 

 You want to run a database 
 that only needs to be reachable from a webserver 
 within the same availability zone (us-east-1b) 
 and within the same VPC. 
 
 You also want to update your database now and then. 
 The binaries that the database server needs to download (the updates) 
 are present on another webserver that's still within the same VPC, 
 but on a subnet within another availability zone (us-east-2b). 
 
 The webserver serves traffic for internet users. 
 
Soln: 

 put webserver in public subnet 
 put DB server in a private subnet 
 
 the DB server will always be able to connect to the download server 
 as long as firewall rules are not blocking ports; 




#### Add EBS volume to instance 
** Make sure to have run ssh-keygen before running terraform apply; 

Check terraform.tfstate for IP given to instance; 

Use that IP to ssh into the machine you just spun up; 

Create filesystem on added volume [device]; 

mount the device; 

add device to a line in fstab; 

unmount, remount, and check for it after reboot; 


 
#### cloud-init 
Reason for using template is so we can pass variables; 



shell script (vs) upstart script 

shell script: content_type = "text/x-shellscript" 

upstart script: content_type = "text/upstart-job" 




#### Route53 
** Use hostnames rather than IP 

register a domain name 
> When you register a domain, you need to add the AWS nameservers to that domain;  
> To know your nameservers for your particular domain, use output resource to output the 
property [aws_route53_zone.example-com.name_servers] ; 

create a zone in route53 (ex: domain.com)

add DNS records (ex: server1.domain.com) 




  





### Project folder structure notes: 


[provider.tf] 

- specify region (variable found in vars.tf) 
- paths to access_key, secret_key optional 


[output.tf] 



[instance] 

- provisioner can be specified within the aws_instance resource (specify connection with it)
- output can be specified here (unless output.tf exists) 
- aws_key_pair resource can be added at the top (otherwise, put keys in key.tf) 



[key.tf] 




[vars.tf] 

- type can = map, holding multiple default values  



[securitygroup.tf] 

- aws_security_group resource can consist of ingress, egress, and tags 
- aws_ip_ranges data can be included, specifying regions and services 
 
 
 
[modules.tf] 




[vpc.tf] 

- create main aws_vpc 
- create aws_subnet resources 
- create aws_internet_gateway 
- create aws_route_table resource that can be pushed to the instances 
- create aws_route_table_associations that are public 



[nat.tf] 

- create an aws_eip resource 
- use eip to create a nat gateway via resource aws_nat_gateway 
- conduct vpc setup for nat via aws_route_table resource 
- for aws_route_table resources, create aws_route_table_association resources that are private 




[terraform.tfstate] 










































