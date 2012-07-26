Vagrant::Config.run do |config|
  config.vm.box     = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.customize do |vm|
    vm.memory_size = 512
  end

  config.vm.network :hostonly, '192.168.42.101'

  # NFS share

  config.vm.share_folder('v-root', '/vagrant', '.', :nfs => true)

  # Puppet

  config.vm.share_folder('puppet-modules', '/tmp/vagrant-puppet/modules', 'config/puppet/puppet-master/modules')

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'config/puppet/manifests'
    puppet.manifest_file  = 'development.pp'

    puppet.options = [
      '--modulepath',  '/tmp/vagrant-puppet/modules'
    ]
  end
end
