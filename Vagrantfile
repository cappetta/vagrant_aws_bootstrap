# -*- mode: ruby -*-
# vi: set ft=ruby :


# SecDevOps Workflow to setup 1-or-Many machines in AWS:
# 1) Install the dependent plugins
# 2) Setup shared folder if they exist
# 3) Execute initialization scripts on Asset
#     a. cloud-init
#     b. shell-> update env, install packages, ruby, puppet
#     c. execute provisioners -> docker, puppet, docker-compose
# handle orchestration and provisioning
# handle networking, ACLs, and security groups		
# implement monitoring and alerting framework		


# How to execute a command during vagrant processing...
# ref_url: http://superuser.com/questions/701735/run-script-on-host-machine-during-vagrant-up
# todo: decom after baselining to vagrantfile master repo
module LocalCommand
  class Config < Vagrant.plugin("2", :config)
    attr_accessor :command
  end

  class Plugin < Vagrant.plugin("2")
    name "local_shell"

    config(:local_shell, :provisioner) do
      Config
    end

    provisioner(:local_shell) do
      Provisioner
    end
  end

  class Provisioner < Vagrant.plugin("2", :provisioner)
    def provision
      result = system "#{config.command}"
    end
  end
end


# handle the plugins dependencies in a nice-easy way
# ref_url: https://github.com/DevNIX/Vagrant-dependency-manager
require File.dirname(__FILE__)+"/vagrant_customizations/dependency_manager"
check_plugins ["vagrant-docker-compose", "vagrant-awsinfo", "vagrant-docker-login", "vagrant-aws","vagrant-docker-login", "vagrant-share", "vagrant-winrm", "vagrant-winrm-syncedfolders"]

# Logic to determine the Operating System of the host...
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

require 'yaml'
creds = YAML.load_file("./yaml/aws.yaml")
aws_facts = YAML.load_file("./yaml/aws_facts.yaml")
nodes = YAML.load_file("./yaml/vagrant.yaml")


Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

 nodes.each do |node|
  config.vm.define node["name"] do |node_config|
    if node["isWindows"]
      config.vm.guest = :windows
      config.vm.communicator = "winrm"
      config.winrm.username = "vagrant"
      config.winrm.password = "vagrant"	
      config.windows.set_work_network = true
      config.winrm.port = 5985
      config.winrm.transport = :plaintext
      config.winrm.max_tries=100
    end
    # setting some global timeout settings
    # config.vm.boot_timeout = 600
    # config.vm.graceful_halt_timeout = 600

  node_config.vm.provider :aws do |aws, override|
      aws.access_key_id = creds['access_key']
      aws.secret_access_key = creds['secret_key']
      aws.keypair_name = node['aws_keypair_name']
      override.ssh.private_key_path = creds['private_key_path']
      aws.region = node["region"]
      aws.ami = node["ami"]
      # aws.elastic_ip = true
      aws.associate_public_ip = true

      if node["vpc_id"]
        aws.tenancy = node['vpc_id']
      end

      aws.ssh_host_attribute = :private_ip_address

      # If default user defined otherwise ec2-user
       if node["user"]
        override.ssh.username = node["user"]
      else
        override.ssh.username = "ec2-user"
      end

      if node["subnet_id"]
        aws.subnet_id = node["subnet_id"]
      end

      # VPC's can have specific security groups
      if node['secgroup_name']
        # puts "Debugging:: Sec Group: " + node['secgroup_name'].join(",")
        aws.security_groups = node['secgroup_name']
      end

      if node["type"]
        aws.instance_type = node["type"]
      else
        aws.instance_type = "t2.micro"
      end
      aws.tags = {
        'Name' => node["name"],
      }
      unless node['userData'].nil?
        aws.user_data = File.read(node['userData'])
      end
    end

      unless node['folders'].nil?
        node['folders'].each do |folder|
          if node["isWindows"]
            node_config.vm.synced_folder folder['local'], folder['virtual'] , type: "winrm"
            node_config.vm.synced_folder "./shared", "/vagrantshared"
            node_config.vm.provision :shell, :path => "./shared/shell/main.cmd"
          else
            node_config.vm.synced_folder folder['local'], folder['virtual'] , type: 'rsync', :mount_options => ['dmode=775', 'fmode=775']
          end
	# todo: if isWindows then sync folders differently...
        end
      end

    node_config.vm.provision "list-files", type: "local_shell", command: "dir"

      unless node["initScript"].nil?
        node["initScript"].each do |script|
          node_config.vm.provision :shell, path: script["init"], privileged: true
          node_config.vm.provision :shell, inline: script["init"], privileged: true, env: {"VAGRANT_HOME" => "/var/vagrant"} #todo: test env variables are being created / captured
        end
      end
    node_config.vm.post_up_message = "System has provisioned successfully -- please validate the boxes ~cappetta"
  end

  # Run Puppet Manifests to setup virtual Desktop env
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = 'puppet/modules'
  end
end

  # now provision Docker stuff
  config.vm.provision :docker
#  config.vm.provision :docker_compose, yml: ["/vagrant/docker/docker_compose.yml"], rebuild: true, project_name: "project_name", run: "always"
  config.vm.provision :docker_login, username: creds["docker_user"], email: creds["docker_email"], password: creds["docker_reg_pass"], server: creds["docker_registry_url"]


  # messages after booting - todo: check provisioning status w/ custom ruby code
  # ref_url: http://stackoverflow.com/questions/30820949/print-message-after-booting-vagrant-machine-with-vagrant-up
#  END {
#    puts "Vagrant Command completed"
#  }

end
