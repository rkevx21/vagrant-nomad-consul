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

server {
  enabled          = true
  bootstrap_expect = 3
  server_join {
    retry_join     = ["192.168.40.30:4648","192.168.40.35:4648","192.168.40.40:4648"]
    retry_max      = 3
    retry_interval = "15s"
  }
}
