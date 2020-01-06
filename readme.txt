
Test/Development Setup : Vagrant + Nomad + Consul + Vault 

    Vagrant
        - Create 3 Node Cluster
        - nodes.json, configuration use for node (hostname,ip address, memory, script)
    
    bootsrap.sh 
        - install docker
        - install docker-compose
        - install jq (use to parse json file)
        * Nomad
            - install Nomad
            - setup Nomad as service
            - Nomad configuration (configuration source : nodes.json)
        * Consul
            - Consul configuration (configuration source : nodes.json)
        * Vault
            - Vault configuration (configuration source : nodes.json)
        
        WHERE : Consul and Vault is setup using docker-compose.yml

    Configuration PATH
        * Nomad
            - /etc/nomad.d/nomad.hcl
        * Consul
            - /etc/consul.d/config.json
        * Vault
            - /etc/vault.d/config/config.hcl
        * docker-compose
            - /etc/consul-vault/docker-compose.yml

    Web UI 
        * Nomad
            - IP:4646
        * Consul
            - IP:8500
        * Vault
            - IP:8200
        
Note : 
    Always run `vagrant up --provsion` so that docker container will automatically start, the script has checking for containers running state
     