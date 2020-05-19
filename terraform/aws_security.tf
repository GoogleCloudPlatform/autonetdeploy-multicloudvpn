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
 * Terraform security (firewall) resources for AWS.
 */

# Allow PING testing.
resource "aws_security_group" "aws-allow-icmp" {
  name        = "aws-allow-icmp"
  description = "Allow icmp access from anywhere"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow SSH for iperf testing.
resource "aws_security_group" "aws-allow-ssh" {
  name        = "aws-allow-ssh"
  description = "Allow ssh access from anywhere"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow traffic from the VPN subnets.
resource "aws_security_group" "aws-allow-vpn" {
  name        = "aws-allow-vpn"
  description = "Allow all traffic from vpn resources"
  vpc_id      = aws_vpc.aws-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.gcp_subnet1_cidr]
  }
}

# Allow TCP traffic from the Internet.
resource "aws_security_group" "aws-allow-internet" {
  name        = "aws-allow-internet"
  description = "Allow http traffic from the internet"
  vpc_id      = aws_vpc.aws-vpc.id

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

