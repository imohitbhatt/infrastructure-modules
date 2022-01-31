# picking up the ami from aws
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    # values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    values = ["amzn2-ami-*-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}