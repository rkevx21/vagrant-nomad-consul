#!/bin/bash

if [ -x "$(command -v docker)" ]; then

    echo "Docker already installed."
    vault_stat=`sudo docker inspect -f '{{.State.Running}}' vault`
    consul_stat=`sudo docker inspect -f '{{.State.Running}}' consul`
    
    if [[ "$vault_stat" = false ]] && [[ "$consul_stat" = false ]]; then
        cd /opt/consul-vault
        sudo docker-compose up -d
    fi 

else

### START docker, docker-compose, jq
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update 
sudo apt-get install -y docker-ce
sudo apt-get install -y docker-compose
sudo service docker restart
sudo docker --version
sudo add-apt-repository universe
sudo apt update
sudo apt install -y jq
### docker, docker-compose, jq END

### START nomad
export NOMAD_VERSION="0.9.0"
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo apt-get install unzip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
sudo rm nomad_${NOMAD_VERSION}_linux_amd64.zip
nomad version
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
sudo mkdir --parents /opt/nomad

(
cat <<-EOF
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINnomadPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service

sudo mkdir --parents /etc/nomad.d
sudo chmod 700 /etc/nomad.d

data=`cat /vagrant/nodes.json | jq -r '.nodes | to_entries[] | [.key, .value.":ip"] | @tsv' | grep $(hostname)`
ips=`jq -c '.nodes | to_entries | map(.value.":ip")| map_values(.+":4648")' /vagrant/nodes.json`

srv=($data)
host=${srv[0]}
ip=${srv[1]}

(
cat <<-EOF
data_dir  = "/opt/nomad"
name      = "$host"
bind_addr = "0.0.0.0"

advertise {
  http = "$ip:4646"
  rpc  = "$ip:4647"
  serf = "$ip:4648"
}

server {
  enabled          = true
  bootstrap_expect = 3
  retry_join       = $ips
}

client {
  enabled       = true
  network_speed = 10
  options {
    "driver.raw_exec.enable" = "1"
  }
}
EOF
) | sudo tee /etc/nomad.d/nomad.hcl

sudo systemctl enable nomad
sudo systemctl start nomad
sudo systemctl status nomad
### nomad END

### START consul, vault
datecenter='local-cluster'
data=`cat /vagrant/nodes.json | jq -r '.nodes | to_entries[] | [.key, .value.":ip"] | @tsv' | grep $(hostname)`
ips=`jq -c '.nodes | to_entries | map(.value.":ip")| map_values(.+":8301")' /vagrant/nodes.json`

srv=($data)
host=${srv[0]}
ip=${srv[1]}

sudo mkdir --parents /etc/consul.d
sudo chmod 700 /etc/consul.d

(
cat <<-EOF
{
  "acl_datacenter": "$datecenter",
  "acl_default_policy": "allow",
  "acl_down_policy": "extend-cache",
  "datacenter": "$datecenter",
  "node_name": "$host",
  "bind_addr": "$ip",
  "bootstrap_expect": 3,
  "client_addr": "0.0.0.0",
  "data_dir": "/consul/data",
  "enable_script_checks": true,
  "dns_config": {
      "enable_truncate": true,
      "only_passing": true
  },
  "encrypt": "UKJcrQZ5oWPmfJBlCQiwoA==",
  "leave_on_terminate": true,
  "log_level": "INFO",
  "rejoin_after_leave": true,
  "server": true,
  "retry_join": $ips,
  "ui": true
}
EOF
) | sudo tee /etc/consul.d/config.json

sudo mkdir /etc/vault.d
sudo chmod 755 /etc/vault.d
sudo mkdir /etc/vault.d/config /etc/vault.d/policies /etc/vault.d/data /etc/vault.d/logs
sudo chmod -R 755 /etc/vault.d

(
cat <<-EOF
storage "consul" {
  address = "$ip:8500"
  path    = "vault/"
}

listener "tcp" {
 address          = "0.0.0.0:8200"
 cluster_address  = "$ip:8201"
 tls_disable = 1
}

api_addr = "http://$ip:8200"
cluster_addr = "https://$ip:8201"

ui = true
EOF
) | sudo tee /etc/vault.d/config/config.hcl

sudo mkdir /opt/consul-vault
sudo chmod 755 /opt/consul-vault

(
cat <<-EOF
version: '3'

services:

  consul:
    hostname: consul
    container_name: "consul"
    image: consul:latest
    network_mode: host
    volumes:
      - /etc/consul.d/:/consul/config
    command:
      consul agent -config-dir=/consul/config/

  vault:
    hostname: vault
    container_name: "vault"
    image: vault:latest
    ports:
      - 8200:8200
    volumes:
      - /etc/vault.d/config/:/vault/config
      - /etc/vault.d/policies:/vault/policies
      - /etc/vault.d/data:/vault/data
      - /etc/vault.d/logs:/vault/logs
    environment:
      - VAULT_ADDR=http://127.0.0.1:8200
    command: vault server -config=/vault/config/
    cap_add:
      - IPC_LOCK
    depends_on:
      - consul
EOF
) | sudo tee /opt/consul-vault/docker-compose.yml

cd /opt/consul-vault
sudo docker-compose up -d
### consul, vault END

fi