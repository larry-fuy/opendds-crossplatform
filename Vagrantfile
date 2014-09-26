# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "dds"
  config.vm.communicator = "winrm"
  config.vm.provider "virtualbox" do |v|
    v.name = "repo_vm"
  end

  config.vm.network "forwarded_port", guest: 15000, host: 15000
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
  config.vm.network "private_network", ip: "196.128.0.2"
  config.vm.provision "shell", path: "./scripts/run_dds_win.bat"
end
