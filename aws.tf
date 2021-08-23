terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.region
}


data "aws_ami" "ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "zones" {

}

resource "aws_security_group" "http" {
  name        = "newweb"
  description = "policy rules for web servers"


    ingress    {
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "http ssh"
  }
}

resource "aws_launch_configuration" "launchconf" {
  name_prefix     = "launchconf"
  image_id        = data.aws_ami.ami.id
  instance_type   = "t2.micro"
  key_name        = var.key-pair
  security_groups = [aws_security_group.http.id]
  user_data       = file("init-script.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autogroup" {
  name_prefix               = "autogroup"
  max_size                  = 9
  min_size                  = 3
  desired_capacity          = 3
  health_check_grace_period = 90
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.front_end.arn]
    //  load_balancers            = [aws_elb.lb.name]
  launch_configuration      = aws_launch_configuration.launchconf.name
  vpc_zone_identifier       = [aws_default_subnet.zone0.id, aws_default_subnet.zone1.id, aws_default_subnet.zone2.id]
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_default_subnet" "zone0" {
  availability_zone = data.aws_availability_zones.zones.names[0]
}

resource "aws_default_subnet" "zone1" {
  availability_zone = data.aws_availability_zones.zones.names[1]
}

resource "aws_default_subnet" "zone2" {
  availability_zone = data.aws_availability_zones.zones.names[2]
}

resource "aws_default_vpc" "vpc" {

}

resource "aws_lb" "front_end" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http.id]
  subnets            = [aws_default_subnet.zone0.id, aws_default_subnet.zone1.id, aws_default_subnet.zone2.id]
  enable_deletion_protection = true

}

resource "aws_lb_target_group" "front_end" {
  name = "targetgroup"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_default_subnet.zone0.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

output "lburl" {
  value = aws_lb.front_end.dns_name
}

resource "aws_route53_record" "www" {
  zone_id = var.route53zoneid
  name    = "alb"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.front_end.dns_name]
}