#
# Cookbook Name:: postgresql_server_master
# Recipe:: server_redhat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "postgresql_server_master::client"

# Create a group and user like the package will.
# Otherwise the templates fail.

group "postgres" do
  gid 26
end

user "postgres" do
  shell "/bin/bash"
  comment "PostgreSQL Server"
  home "/var/lib/pgsql"
  gid "postgres"
  system true
  uid 26
  supports :manage_home => false
end

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

execute "/sbin/service #{node['postgresql']['server']['service_name']} initdb" do
  not_if { ::FileTest.exist?(File.join(node['postgresql']['dir'], "PG_VERSION")) }
end

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
