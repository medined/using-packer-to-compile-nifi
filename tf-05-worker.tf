
# ..######..########..######..##.....##.########..####.########.##....##
# .##....##.##.......##....##.##.....##.##.....##..##.....##.....##..##.
# .##.......##.......##.......##.....##.##.....##..##.....##......####..
# ..######..######...##.......##.....##.########...##.....##.......##...
# .......##.##.......##.......##.....##.##...##....##.....##.......##...
# .##....##.##.......##....##.##.....##.##....##...##.....##.......##...
# ..######..########..######...#######..##.....##.####....##.......##...

# ..######...########...#######..##.....##.########.
# .##....##..##.....##.##.....##.##.....##.##.....##
# .##........##.....##.##.....##.##.....##.##.....##
# .##...####.########..##.....##.##.....##.########.
# .##....##..##...##...##.....##.##.....##.##.......
# .##....##..##....##..##.....##.##.....##.##.......
# ..######...##.....##..#######...#######..##.......

resource "aws_security_group" "worker" {
  name = "${var.vpc_name}-worker-security-group"
  vpc_id = aws_vpc.vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# .####.##....##..######..########....###....##....##..######..########
# ..##..###...##.##....##....##......##.##...###...##.##....##.##......
# ..##..####..##.##..........##.....##...##..####..##.##.......##......
# ..##..##.##.##..######.....##....##.....##.##.##.##.##.......######..
# ..##..##..####.......##....##....#########.##..####.##.......##......
# ..##..##...###.##....##....##....##.....##.##...###.##....##.##......
# .####.##....##..######.....##....##.....##.##....##..######..########

#
# If subnet_id is not specified, then the default vpc is used.
# Make sure the subnet is inside the selected availability_zone.
#
resource "aws_instance" "worker" {
  ami                         = data.aws_ami.worker.id
  iam_instance_profile        = aws_iam_instance_profile.worker.id
  instance_type               = "m5.large"
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true
  tags = {
    Name = "${var.vpc_name}-worker"
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "100"
    delete_on_termination = true
  }
  # Run a remote exec to wait for the server to be ready for SSH.
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.key_private_file)
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done",
    ]
  }
}
