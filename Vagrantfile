`# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
	# Base box to build off, and download URL for when it doesn't exist on the user's system already
	config.vm.box = "ubuntu/xenial64"
	config.vm.box_url = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box"

	# Boot with a GUI so you can see the screen. (Default is headless)
	# config.vm.boot_mode = :gui
	
	# Assign this VM to a host only network IP, allowing you to access it
	# via the IP.
	config.vm.network "192.168.77.77"

	# Use your local SSH keys on the box 
	config.ssh.forward_agent = true
	
	# Port forwarding from the guest to the host
	config.vm.network :forwarded_port, host: 8000, guest: 8000
	#Forward the postgres port if you want to be able to connect to it from pgadmin or datagrip
	config.vm.network :forwarded_port, host: 8432, guest: 5432
		
	# Share an additional folder to the guest VM. The first argument is
	# an identifier, the second is the path on the guest to mount the
	# folder, and the third is the path on the host to the actual folder.
	config.vm.share_folder "project", "/home/vagrant/{{ project_name }}", "."

	config.vm.provider "virtualbox" do |v|
		v.memory = 3092
		v.cpus = 1
	end
	
	# Enable provisioning with a shell script.
	config.vm.provision :shell, :path => "etc/install/install.sh", :args => "{{ project_name }}"
end

