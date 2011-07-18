service "nginx" do
  action [ :stop, :disable]
end

package "nginx" do
  action [:purge]
end
