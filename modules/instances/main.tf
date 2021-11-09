data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "launch_configuration_ec2" {
  name_prefix = "launch-configuration-ec2-${var.project_name}-${terraform.workspace}"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.nano"
  associate_public_ip_address = false

  key_name = var.ec2_keyname
  user_data = filebase64("${path.module}/apache-install.sh")
  security_groups = [aws_security_group.sg_ec2.id]

  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg_ec2" {
  name        = "ec2-${var.project_name}-${terraform.workspace}"
  description = "for ${var.project_name} webserver"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "HTTP from ELB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    security_groups  = [var.sg_alb_id]
  }

  egress {
    description      = "Out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ec2-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_autoscaling_group" "asg_ec2" {
  name = "asg-ec2-${var.project_name}-${terraform.workspace}"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier = var.vpc_private_subnets_id

  target_group_arns = [var.alb_target_group_arn] # ALB target
  launch_configuration = aws_launch_configuration.launch_configuration_ec2.name

  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "asg_ec2_policy" {
  name = "asg-policy-${var.project_name}-${terraform.workspace}"
  autoscaling_group_name = aws_autoscaling_group.asg_ec2.name
  policy_type = "TargetTrackingScaling" # Scale in or out to keep CPU utilization around 50%
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}