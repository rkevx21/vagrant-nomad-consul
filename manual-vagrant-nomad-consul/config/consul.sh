#!/bin/bash

echo "Consul Installer"
echo "======================================================================"
echo "Installing Consul..........."

IP="192.168.40.30"
CONSUL_VERSION="1.7.2"

curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul --version

consul -autocomplete-install
complete -C /usr/local/bin/consul consul

sudo mkdir --parents /opt/consul

(
cat <<-EOF
  [Unit]
  Description="HashiCorp Consul - A service mesh solution"
  Documentation=https://www.consul.io/
  Requires=network-online.target
  After=network-online.target

  [Service]
  ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/ -bind=${IP}
  ExecReload=/usr/local/bin/consul reload
  KillMode=process
  Restart=on-failure
  LimitNOFILE=65536

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service

sudo mkdir --parents /etc/consul.d
sudo chown --recursive consul:consul /etc/consul.d

sudo systemctl enable consul
sudo systemctl start consul
sudo systemctl status consul

echo "======================================================================"
echo "Consul Installation DONE"