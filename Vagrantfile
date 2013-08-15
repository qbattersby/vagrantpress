# -*- mode: ruby -*-
# vi: set ft=ruby :
require './vagrant/MysqlBackupPlugin.rb'
require './vagrant/WPCLI_Wrapper.rb'
require './vagrant/dns/vagrant-dnsmasq.rb'

Vagrant.configure("2") do |config|

  config.vm.box = "precise64"  
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :private_network, ip: "192.168.192.168"

  # config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.synced_folder "projects", "/shared_projects" # @todo 
  config.vm.synced_folder "my.conf", "/my.conf" # @todo 

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
    
  end

  config.vm.provision :puppet do |puppet|
   puppet.manifests_path = "puppet/manifests"
   puppet.module_path = "puppet/modules"
   puppet.manifest_file  = "vagrantpress.pp"
   puppet.options = ["--verbose"]
  end



  # for dnsmasq handling
  config.dnsmasq.ip = '192.168.192.168'
  config.dnsmasq.keep_resolver_on_destroy = true
  config.dnsmasq.resolver = '/etc/resolver'


end
