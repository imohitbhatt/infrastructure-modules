variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"
    description = "CIDR block for the VPC"
}

variable "subnet_cidr_block" {
    type = string
    default = "10.0.10.0/24"
    description = "CIDR block for the Subnet"
}

variable "env_prefix" {
    type = string
    description = "prefix for the environment type"
}

variable "avail_zone" {
    type = string
    description = "availability zone"
}
variable "my_ip" {
    type = string
    description = "IP of my local system used in the ingress rule for allowing my pc to ssh"
}
variable "instance_type" {
    type = string
    description = "type of instance required for autoscaling"
}
variable "public_key_location" {
    type = string
    description = "path to the public key i.e., 'rsa.pub' in my local system"
}

variable "bucket_id" {
    type = string
    description = "used for specifying the unique id for the bucket"
}