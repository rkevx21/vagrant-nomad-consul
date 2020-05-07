#!/bin/bash

echo "Consul Template Installer"
echo "======================================================================"
echo "Installing Consul Template..........."

CONSUL_TEMPLATE_VERSION="0.25.0"

curl --silent --remote-name https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
mv consul-template /usr/local/bin/consul-template
chmod +x /usr/local/bin/consul-template
sudo mkdir /etc/consul-template.d
echo "======================================================================"
echo "Consul Template Installation DONE"