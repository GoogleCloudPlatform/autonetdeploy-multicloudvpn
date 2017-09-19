# Automated Network Deployment: Multicloud VPN - GCP-AWS VPN

Disclaimer: This is not an official Google product.

Demonstration of Terraform for automated deployment of network infrastructure in
both Google Cloud Platform (GCP) and Amazon Web Services (AWS). This is a
multi-cloud VPN setup.

You can look at an [architecture diagram for this setup
here](images/autonetdeploy_gcpawsvpn_arch.png).

See https://github.com/GoogleCloudPlatform/autonetdeploy-startup.git for the
required procedure for setting up the environment with credentials for this
tutorial.

## Quick Start

*   Select project gcp-automated-networks.
*   Activate Google Cloud Shell. Use Cloud Shell because the Google Cloud SDK
    (gcloud) and other tools are included.
*   git clone
    https://github.com/GoogleCloudPlatform/autonetdeploy-multicloudvpn.git
*   cd autonetdeploy-multicloudvpn
*   Install Terraform: ./get_terraform.sh
    *   export PATH=${HOME}/terraform:$ {PATH}
*   Setup for AWS.
    *   After you sign in to the AWS Management Console, navigate to the VPC
        Dashboard and select the Oregon region.
    *   ./aws_set_credentials.sh exists
*   Setup for GCP.
    *   ./gcp_set_credentials.sh exists
    *   gcloud config set project [YOUR-PROJECT_ID]
    *   ./gcp_set_project.sh
*   Run Terraform.
    *   pushd ./terraform
    *   Examine configuration files.
    *   terraform init
    *   terraform validate
    *   terraform plan
    *   terraform apply
    *   terraform output
    *   terraform show
    *   gcloud compute instances list
    *   ssh -i ~/.ssh/vm-ssh-key [GCP_EXTERNAL_IP]
    *   ping -c 5 google.com
    *   curl ifconfig.co/ip
    *   Run iperf over external route: /tmp/run_iperf_to_ext.sh
    *   Run iperf over VPN route: /tmp/run_iperf_to_int.sh
    *   exit
    *   ssh -i ~/.ssh/vm-ssh-key [AWS_EXTERNAL_IP]
    *   ping -c 5 google.com
    *   curl ifconfig.co/ip
    *   Run iperf over external route: /tmp/run_iperf_to_ext.sh
    *   Run iperf over VPN route: /tmp/run_iperf_to_int.sh
    *   exit
*   Clean up
    *   terraform plan -destroy
    *   terraform destroy
    *   terraform show
    *   popd

## References

*   [GCP Cloud VPN Overview](https://cloud.google.com/compute/docs/vpn/overview)
*   [GCP Creating a
    VPN](https://cloud.google.com/compute/docs/vpn/creating-vpns)
*   [GCP VPN Interoperability
    Guides](https://cloud.google.com/compute/docs/vpn/interop-guides)
*   [AWS VPN
    Connections](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpn-connections.html)

## License

Copyright 2017 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
