#
# Cookbook Name:: php-env
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when 'amazon'
  %w{php56 php56-fpm php56-opcache php56-mbstring php56-mcrypt php56-mysqlnd php56-pgsql php56-gd}.each do |pkg|
    package pkg do
      action :install
      notifies :restart, "service[php-fpm]"
    end
  end
else
    %w{php php-fpm php-opcache php-mbstring php-mcrypt php-mysql php-pgsql php-sqlite php-gd}.each do |pkg|
    package pkg do
      action :install
      notifies :restart, "service[php-fpm]"
    end
    yum_repository "remi" do
      description "Les RPM de Remi - Repository"
      baseurl "http://rpms.famillecollet.com/enterprise/6/remi/x86_64/"
      gpgkey "http://rpms.famillecollet.com/RPM-GPG-KEY-remi"
      fastestmirror_enabled true
      action :create
    end

    yum_repository "remi-php56" do
      description "Les RPM de Remi de PHP 5.6 our Enterprise Linux 6"
      baseurl "http://rpms.famillecollet.com/enterprise/7/php56/$basearch/"
      gpgkey "http://rpms.famillecollet.com/RPM-GPG-KEY-remi"
      fastestmirror_enabled true
      action :create
    end
  end
end

template '/etc/php.ini' do
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[php-fpm]"
end

template '/etc/php-fpm.d/www.conf' do
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[php-fpm]"
end

service "php-fpm" do
  action [ :enable, :start ]
end

bash 'install wordpress' do
  creates '/usr/share/nginx/html/wordpress'
  cwd '/usr/share/nginx/html'
  code <<-EOH
  curl -LO https://wordpress.org/latest.tar.gz
  tar zxvf latest.tar.gz
  EOH
end
