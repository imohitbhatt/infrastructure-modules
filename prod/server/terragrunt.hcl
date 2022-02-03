include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../module//aws-module"
}


inputs = {
  instance_type       = "t2.micro"
  avail_zone          = "ap-south-1a"
  env_prefix          = "prod"
  vpc_cidr_block      = "10.0.0.0/16"
  subnet_cidr_block   = "10.0.10.0/24"
  my_ip               = "203.129.220.226/32"
  public_key_location = "/home/xs162-mohbha/.ssh/id_rsa.pub"
  bucket_id           = "prod-bucket-infra-test-01"
}