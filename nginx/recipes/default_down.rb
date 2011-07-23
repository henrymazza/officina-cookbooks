service "nginx" do
  action [ :stop, :disable]
  only_if "test -e /etc/init.d/nginx"
end

package "nginx" do
  action [:purge]
end
