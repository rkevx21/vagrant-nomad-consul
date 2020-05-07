#!/bin/bash

echo "Nomad Installer"
echo "======================================================================"
echo "Installing Nomad..........."

export NOMAD_VERSION="0.11.1"

curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip

sudo apt-get install unzip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
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
  ExecReload=/bin/kill -HUP $MAINPID
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

sudo systemctl enable nomad
sudo systemctl start nomad
sudo systemctl status nomad

echo "======================================================================"
echo "Nomad Installation DONE"

