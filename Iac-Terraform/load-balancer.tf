resource "aws_lb" "todo_lb" {
  name               = "todo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls2.id ,aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.subnet_2.id, aws_subnet.subnet_1.id]

  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "todo-listener" {
  load_balancer_arn = aws_lb.todo_lb.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo-target.arn
  }
}

resource "aws_lb_target_group" "todo-target" {
  name     = "tf-todo-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.to-vpc.id

}


resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.todo-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo-target.arn
  }

  condition {
    host_header {
      values = ["my-service.*.terraform.io"]
    }
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.todo-target.arn
  target_id        = aws_instance.web.id
  port             = 80
}


resource "aws_lb_listener_rule" "path_based_routing" {
  listener_arn = aws_lb_listener.todo-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo-target.arn
  }

  condition {
    path_pattern {
      values = ["/foo", "/bar"]
    }
  }
}

resource "aws_launch_template" "to-do-temp" {
  name_prefix   = "to-do-temp"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "to-do-asg" {
  name_prefix          = "to-do-asg"
  availability_zones = ["eu-north-1a" , "eu-north-1b"]
 # vpc_zone_identifier = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.to-do-temp.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.to-do-asg.name
  lb_target_group_arn    = aws_lb_target_group.todo-target.arn
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}