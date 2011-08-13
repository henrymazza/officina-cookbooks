include_recipe "build-essential"
include_recipe "runit"
include_recipe "rvm"

# Comment: ubuntu specific!
['libcurl4-openssl-dev','libpcre3-dev', 'curl'].each do |pkg|
  package pkg
end

# install essential gems only in default ruby (1.9.2)
["passenger", "bundler"].each do |gem|
  gem_package gem do
    gem_binary "/usr/local/rvm/bin/rvm default exec gem"
  end
end

node.set[:nginx][:daemon_disable]  = true
node.default[:nginx][:passenger_root] = `/usr/local/rvm/bin/rvm default exec passenger-config --root` 

# override default attributes for the binary

node.override["nginx"]["src_binary"] = "/opt/nginx/sbin/nginx"
nginx_version = node[:nginx][:version]

remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}.tar.gz" do
  source "http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

bash "Extract Nginx Source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf nginx-#{nginx_version}.tar.gz
  EOH
  creates "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}/"
end

bash "install passenger/nginx from rvm" do
  user "root"
  code <<-EOH
  /usr/local/rvm/bin/rvm exec passenger-install-nginx-module --auto --nginx-source-dir="#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}" --prefix="/opt/nginx-passenger/" --extra-configure-flags="#{node[:nginx][:passenger_flags]} "
  EOH
  creates node[:nginx][:src_binary]
end

bash "change owner of nginx dir" do
  user "root"
  code "chown #{node[:nginx][:user]}:#{node[:nginx][:group]} -R /opt/nginx-passenger/"
end

link "Linking Passenger's nginx." do
  target_file "/opt/nginx"
  to "/opt/nginx-passenger/"
  owner "root"
  not_if "test -e /opt/nginx/sbin/nginx"
end

runit_service "nginx"

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

template "nginx-passenger.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx-passenger.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

nginx_site "default" 

directory "/var/www/nginx-default" do
  owner node[:nginx][:user]
  recursive true
end

template "/var/www/nginx-default/index.html" do
  owner node[:nginx][:user]
  source "index.html.erb"
end
