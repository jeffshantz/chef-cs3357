#
# Cookbook Name:: cs3357
# Recipe:: web
#
# Copyright (C) 2014, Jeff Shantz
#
# All rights reserved - Do Not Redistribute

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

include_recipe 'torquebox::server'

service 'torquebox' do
  action  [:enable, :start]
end

