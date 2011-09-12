default[:nginx][:version]      = "1.0.4"

case platform
when "debian","ubuntu"
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:group]   = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
else
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:group]   = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
end

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_http_version] = "1.1"
default[:nginx][:gzip_comp_level] = "3"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_types] = [
  "text/plain",
  "text/html",
  "text/css",
  "application/x-javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript",
  "application/json"
]

default[:nginx][:keepalive]          = "on"
default[:nginx][:keepalive_timeout]  = 65
default[:nginx][:worker_processes]   = cpu[:total]
default[:nginx][:worker_connections] = 2048
default[:nginx][:server_names_hash_bucket_size] = 64

default[:nginx][:passenger_flags] = '--with-ipv6 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --without-mail_pop3_module --without-mail_smtp_module --without-mail_imap_module'

