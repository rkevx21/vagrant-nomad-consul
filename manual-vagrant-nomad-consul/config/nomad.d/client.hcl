region             = "ph"
datacenter         = "reth-1a"

data_dir           = "/opt/nomad"
name               = "s1"
bind_addr          = "0.0.0.0"

advertise {
  http             = "192.168.40.30:4646"
  rpc              = "192.168.40.30:4647"
  serf             = "192.168.40.30:4648"
}

client {
  enabled          = true
  server_join {
    retry_join     = ["192.168.40.30:4647","192.168.40.35:4647","192.168.40.40:4647"]
    retry_max      = 3
    retry_interval = "15s"
  }

  network_speed    = 1000
  options {
    "driver.raw_exec.enable" = "1"
  }

  node_class       = "reth-apps"
  meta {
    "owner"        = "rethkevin"
    "hypervisor"   = "vagrant"
  }
}

### disable docker instance on server
plugin "docker" {
  gc {
    image = false
    container = false
  }
}
