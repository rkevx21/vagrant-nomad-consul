consul {
    address = "localhost:8500"
    retry {
        enabled = true
        attempts = 12
        backoff = "250ms"
    }
}
template {
    source      = "/etc/consul-template.d/load-balance/load-balancer.conf.ctmpl"
    destination = "/etc/nginx/conf.d/load-balancer.conf"
    perms = 0600
    command = "sudo nginx -s reload"
}

# sudo /usr/local/bin/consul-template -config load-balancer.config.hcl -once