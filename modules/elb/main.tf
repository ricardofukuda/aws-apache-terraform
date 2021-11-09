
# Application Load Balancer configs
resource "aws_lb" "alb" {
  name               = "alb-${var.project_name}-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.vpc_public_subnets_id

  enable_deletion_protection = false

  tags = {
    Name = "alb-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-target-group-${var.project_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_security_group" "sg_alb" {
  name        = "alb-sg-${var.project_name}-${terraform.workspace}"
  description = "for webserver"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "web port"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups  = []
      self             = false
    }
  ]
  egress  = [
    {
      description      = "Out"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "alb-sg-${var.project_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

