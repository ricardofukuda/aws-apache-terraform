# Terraform for Apache webserver on AWS

##Contains:
- VPC with private and public subnets (total 4 subnets because uses secondary AZ for high availability);
- EC2 instances running Apache webserver (in private subnet);
- Application Load Balancer (in public subnet);
- EC2/ELB AutoScalingGroup with target scaling policy of 50% CPU utilization;
- InternetGateway for public subnet and NatGateway for private subnet isolation;
- CloudFront Distribution with two origins:
-- Path "/static/" to provide access and cache to static files from private S3 Bucket;
-- Path "/" to foward request to the Application Load Balancer;
- Route53 public hosted zone to alias CloudFront Distribution dns for fast content delivery;
