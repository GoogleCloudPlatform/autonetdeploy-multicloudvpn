/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Terraform compute resources for AWS.
 */

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.aws_disk_image]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "aws-ip" {
  vpc = true

  instance                  = aws_instance.aws-vm.id
  associate_with_private_ip = var.aws_vm_address
}

resource "aws_instance" "aws-vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.aws-subnet1.id
  key_name      = "vm-ssh-key"

  associate_public_ip_address = true
  private_ip                  = var.aws_vm_address

  vpc_security_group_ids = [
    aws_security_group.aws-allow-icmp.id,
    aws_security_group.aws-allow-ssh.id,
    aws_security_group.aws-allow-vpn.id,
    aws_security_group.aws-allow-internet.id,
  ]

  user_data = replace(
    replace(
      file("vm_userdata.sh"),
      "<EXT_IP>",
      google_compute_address.gcp-ip.address,
    ),
    "<INT_IP>",
    var.gcp_vm_address,
  )

  tags = {
    Name = "aws-vm-${var.aws_region}"
  }
}

