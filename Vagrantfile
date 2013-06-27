# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise64"  
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :private_network, ip: "192.168.92.68"

  # config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.synced_folder "projects", "/shared_projects" # @todo 

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provision :puppet do |puppet|
   puppet.manifests_path = "puppet/manifests"
   puppet.module_path = "puppet/modules"
   puppet.manifest_file  = "init.pp"
   puppet.options = ["--verbose"]
  end
end
