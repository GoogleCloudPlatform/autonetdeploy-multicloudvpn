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
 * Terraform security (firewall) resources for GCP.
 */

# Allow PING testing.
resource "google_compute_firewall" "gcp-allow-icmp" {
  name    = "${google_compute_network.gcp-network.name}-gcp-allow-icmp"
  network = "${google_compute_network.gcp-network.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow SSH for iperf testing.
resource "google_compute_firewall" "gcp-allow-ssh" {
  name    = "${google_compute_network.gcp-network.name}-gcp-allow-ssh"
  network = "${google_compute_network.gcp-network.name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow traffic from the VPN subnets.
resource "google_compute_firewall" "gcp-allow-vpn" {
  name    = "${google_compute_network.gcp-network.name}-gcp-allow-vpn"
  network = "${google_compute_network.gcp-network.name}"

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  source_ranges = [
    "${var.aws_subnet1_cidr}"
  ]
}

# Allow TCP traffic from the Internet.
resource "google_compute_firewall" "gcp-allow-internet" {
  name    = "${google_compute_network.gcp-network.name}-gcp-allow-internet"
  network = "${google_compute_network.gcp-network.name}"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}
