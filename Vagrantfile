# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise64"  
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :private_network, ip: "192.168.192.168"

  # config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.synced_folder "projects", "/shared_projects" # @todo 

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provision :puppet do |puppet|
   puppet.manifests_path = "puppet/manifests"
   puppet.module_path = "puppet/modules"
   puppet.manifest_file  = "vagrantpress.pp"
   puppet.options = ["--verbose"]
  end

  # use https://github.com/mattes/vagrant-dnsmasq plugin
  # for dnsmasq handling
  # @todo 
  config.dnsmasq.domain = '.wp'
  config.dnsmasq.dnsmasqconf = `brew --prefix`.strip + '/etc/dnsmasq.conf'
  config.dnsmasq.keep_resolver_on_destroy = true
end
