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
 * Terraform networking resources for GCP.
 */

resource "google_compute_network" "gcp-network" {
  name                    = "gcp-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gcp-subnet1" {
  name          = "gcp-subnet1"
  ip_cidr_range = var.gcp_subnet1_cidr
  network       = google_compute_network.gcp-network.name
  region        = var.gcp_region
}

/*
 * ----------VPN Connection----------
 */

resource "google_compute_address" "gcp-vpn-ip" {
  name   = "gcp-vpn-ip"
  region = var.gcp_region
}

resource "google_compute_vpn_gateway" "gcp-vpn-gw" {
  name    = "gcp-vpn-gw-${var.gcp_region}"
  network = google_compute_network.gcp-network.name
  region  = var.gcp_region
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gw.self_link
}

/*
 * ----------VPN Tunnel1----------
 */

resource "google_compute_vpn_tunnel" "gcp-tunnel1" {
  name          = "gcp-tunnel1"
  peer_ip       = aws_vpn_connection.aws-vpn-connection1.tunnel1_address
  shared_secret = aws_vpn_connection.aws-vpn-connection1.tunnel1_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gw.self_link

  router = google_compute_router.gcp-router1.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router1" {
  name    = "gcp-router1"
  region  = var.gcp_region
  network = google_compute_network.gcp-network.name
  bgp {
    asn = aws_customer_gateway.aws-cgw.bgp_asn
  }
}

resource "google_compute_router_peer" "gcp-router1-peer" {
  name            = "gcp-to-aws-bgp1"
  router          = google_compute_router.gcp-router1.name
  region          = google_compute_router.gcp-router1.region
  peer_ip_address = aws_vpn_connection.aws-vpn-connection1.tunnel1_vgw_inside_address
  peer_asn        = var.GCP_TUN1_VPN_GW_ASN
  interface       = google_compute_router_interface.router_interface1.name
}

resource "google_compute_router_interface" "router_interface1" {
  name       = "gcp-to-aws-interface1"
  router     = google_compute_router.gcp-router1.name
  region     = google_compute_router.gcp-router1.region
  ip_range   = "${aws_vpn_connection.aws-vpn-connection1.tunnel1_cgw_inside_address}/${var.GCP_TUN1_CUSTOMER_GW_INSIDE_NETWORK_CIDR}"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel1.name
}

/*
 * ----------VPN Tunnel2----------
 */

resource "google_compute_vpn_tunnel" "gcp-tunnel2" {
  name          = "gcp-tunnel2"
  peer_ip       = aws_vpn_connection.aws-vpn-connection1.tunnel2_address
  shared_secret = aws_vpn_connection.aws-vpn-connection1.tunnel2_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gw.self_link

  router = google_compute_router.gcp-router2.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router2" {
  name    = "gcp-router2"
  region  = var.gcp_region
  network = google_compute_network.gcp-network.name
  bgp {
    asn = aws_customer_gateway.aws-cgw.bgp_asn
  }
}

resource "google_compute_router_peer" "gcp-router2-peer" {
  name            = "gcp-to-aws-bgp2"
  router          = google_compute_router.gcp-router2.name
  region          = google_compute_router.gcp-router2.region
  peer_ip_address = aws_vpn_connection.aws-vpn-connection1.tunnel2_vgw_inside_address
  peer_asn        = var.GCP_TUN2_VPN_GW_ASN
  interface       = google_compute_router_interface.router_interface2.name
}

resource "google_compute_router_interface" "router_interface2" {
  name       = "gcp-to-aws-interface2"
  router     = google_compute_router.gcp-router2.name
  region     = google_compute_router.gcp-router2.region
  ip_range   = "${aws_vpn_connection.aws-vpn-connection1.tunnel2_cgw_inside_address}/${var.GCP_TUN2_CUSTOMER_GW_INSIDE_NETWORK_CIDR}"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel2.name
}

