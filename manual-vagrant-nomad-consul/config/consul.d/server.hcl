datacenter         = "reth-1a"
data_dir           = "/opt/consul"
node_name          = "s1"
server             = true
client_addr        = "0.0.0.0"
bind_addr          = "192.168.40.30"
encrypt            = "iFNyI/k4o5dxceky4WSVq855lxfVI1SBmJswCnjU3s8="
bootstrap_expect   = 3
retry_join         = ["192.168.40.30:8301","192.168.40.35:8301","192.168.40.40:8301"]
rejoin_after_leave = true
leave_on_terminate = true
connect {
    enabled        = true
}
ui                 = true
enable_syslog      = true
log_level          = "INFO"
