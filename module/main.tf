resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

# Creating subnet inside our VPC
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

# Connecting VPC to the internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# Configuring route table
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

# route table association to the subnet
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}
resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}


# creating a key pair
resource "aws_key_pair" "var.env_prefix" {
  key_name   = "${var.env_prefix}-key"
  public_key = file(var.public_key_location)
}

resource "aws_launch_configuration" "myapp-web" {
  image_id                    = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.var.env_prefix.key_name
  security_groups             = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true

  user_data = "${file("script.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "var.env_prefix" {
  name                      = "${var.env_prefix}-elb"
  security_groups           = [aws_security_group.myapp-sg.id]
  subnets                   = [aws_subnet.myapp-subnet-1.id]
  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    target              = "HTTP:80/phpinfo.php"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"

  }
}

resource "aws_autoscaling_group" "myapp-asg" {
  name = "${aws_launch_configuration.myapp-web.name}-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  health_check_type    = "ELB"
  load_balancers       = [aws_elb.var.env_prefix.id]
  launch_configuration = aws_launch_configuration.myapp-web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [aws_subnet.myapp-subnet-1.id]



  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.env_prefix}-server-asg"
    propagate_at_launch = true
  }
}
# Target tracking policy
resource "aws_autoscaling_policy" "myapp-ttp" {
  name                      = "myapp-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.myapp-asg.name
  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
