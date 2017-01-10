# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true
  config.vm.box = "boxcutter/ubuntu1604"
  config.vm.network "private_network", ip: "10.2.2.200"
  config.vm.network :forwarded_port, host: 8000, guest: 8000, :auto_correct => true
  config.vm.network :forwarded_port, host: 8001, guest: 5432, :auto_correct => true
#  config.vm.network "public_network"
  config.vm.synced_folder ".", "/home/vagrant/{{ Project_Name }}", :id => "vagrant-root", :nfs => true
  
  config.vm.provision "shell" do |s|
    s.path = "etc/install/install.sh"
    s.args   = "'{{ Project_Name }}'"
  end
end
  
