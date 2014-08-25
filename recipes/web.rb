#
# Cookbook Name:: cs3357
# Recipe:: web
#
# Copyright (C) 2014, Jeff Shantz
#
# All rights reserved - Do Not Redistribute

################################################################################
# Packages                                                                     #
################################################################################

package 'nodejs' do
  action :install
end

################################################################################
# Database configuration                                                       #
################################################################################

node.set[:mysql][:server_root_password] = node[:cs3357][:database][:root_password]

include_recipe 'mysql::server'
include_recipe 'database::mysql'

connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => node[:cs3357][:database][:root_password]
}

# create database
mysql_database node[:cs3357][:database][:name] do
  connection connection_info
  action     :create
end

mysql_database_user node[:cs3357][:database][:user] do
  connection connection_info
  password   node[:cs3357][:database][:password]
  action     :create
end

mysql_database_user node[:cs3357][:database][:user] do
  connection    connection_info
  database_name node[:cs3357][:database][:name]
  privileges    [:all]
  action        :grant
end

################################################################################
# Nginx reverse proxy configuration                                            #
################################################################################

include_recipe 'nginx'

if node[:cs3357][:ssl][:enabled]

  file "/etc/ssl/certs/#{node[:cs3357][:domain]}.crt.pem" do
    content node[:cs3357][:ssl][:certificate]
    owner   'root'
    group   'root'
    mode    0644
    action  :create
  end
  
  file "/etc/ssl/private/#{node[:cs3357][:domain]}.key.pem" do
    content node[:cs3357][:ssl][:key]
    owner   'root'
    group   'root'
    mode    0640
    action  :create
  end

end

file File.join(node[:nginx][:dir], 'conf.d', 'default.conf') do
  action :delete
  notifies :restart, 'service[nginx]'
end

template File.join(node[:nginx][:dir], 'sites-available', 'cs3357') do
  source   'cs3357.conf.erb'
  owner    'root'
  group    'root'
  mode     '0644'
  action   :create
  notifies :restart, 'service[nginx]'
end

nginx_site 'default' do
  enable false
end

nginx_site 'cs3357' do
  enable true
  timing :immediately
end

################################################################################
# Torquebox                                                                    #
################################################################################

include_recipe 'torquebox::server'

service 'torquebox' do
  action  [:enable, :start]
end

################################################################################
# Torquebox user                                                               #
################################################################################

user 'torquebox' do
  shell  '/bin/bash'
  action :modify
end

directory '/opt/torquebox/.ssh' do
  mode      0700
  recursive true
  owner     'torquebox'
  group     'torquebox'
end

remote_file 'Copy authorized_keys' do 
  path   '/opt/torquebox/.ssh/authorized_keys'
  source 'file:///home/ubuntu/.ssh/authorized_keys'
  owner  'torquebox'
  group  'torquebox'
  mode   0600
end

file '/etc/sudoers.d/100-torquebox' do
  content 'torquebox ALL=(ALL) NOPASSWD:ALL'
  owner  'root'
  group  'root'
  mode   0440
end

cookbook_file '/opt/torquebox/.bashrc' do
  source 'bashrc'
  owner  'torquebox'
  group  'torquebox'
  mode   0644
end
