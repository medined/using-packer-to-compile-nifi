#
# This finds the latest custom AMI.
#
data "aws_ami" "worker" {
  most_recent = true
  owners = ["392160515406"]

  filter {
      name   = "name"
      values = ["packer-centos-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
    state = "available"
}

output "worker_ami" {
  value = {
    "id": data.aws_ami.worker.id,
    "name": data.aws_ami.worker.name
  }
}
