VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise32"

  config.vm.define :squid do |squid_config|
    squid_config.vm.network :private_network, ip: "192.168.33.10"
    config.vm.provision :shell, path: "provision.sh"
  end
end
