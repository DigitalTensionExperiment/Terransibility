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



































