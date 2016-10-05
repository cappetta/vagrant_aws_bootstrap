# -*- mode: ruby -*-
# vi: set ft=ruby :




# DevOps Workflow
  # install the dependent plugins
  # handle conditionals shared folder, init scripts
  # handle orchestration and provisioning
  # handle networking, ACLs, and security groups
  # implement monitoring and alerting framework

  # container orchestration
unless Vagrant.has_plugin?("vagrant-docker-compose")
  system("vagrant plugin install vagrant-docker-compose")
  puts "Dependencies installed, please try the command again."
end

unless Vagrant.has_plugin?("vagrant-aws")
  system("vagrant plugin install vagrant-aws")
  puts "Dependencies installed, please try the command again."
end

# Logic to determine the Operating System - future customization needs
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

# If windows do not install the RSYNC plugin
if OS.windows?
  puts "Vagrant launched from windows."
else
  puts "Vagrant launched from mac."
  unless Vagrant.has_plugin?("vagrant-gatling-rsync")
    system("vagrant plugin install vagrant-gatling-rsync")
    puts "Rsync Dependency installed, please try the command again."
  end
end

require 'yaml'
nodes = YAML.load_file("./yaml/vagrant.yaml")
creds = YAML.load_file("./yaml/vagrant.creds")

Vagrant.configure("2") do |config|

  config.vm.box = "dummy"
  nodes.each do |node|
    config.vm.define node["name"] do |node_config|
      node_config.vm.box = node["box"]

      node_config.vm.provider :aws do |aws, override|
        aws.user_data = "#!/bin/bash\necho Defaults:centos \!requiretty >> /etc/sudoers"
        aws.access_key_id = creds['access_key_id']
        aws.secret_access_key = creds['secret_access_key']
        aws.keypair_name = creds['aws_keypair_name']
        override.ssh.private_key_path = creds['private_key_path']
        # puts ' keypath ', creds['private_key_path']
        aws.region = node["region"]
        aws.ami = node["ami"]

        if node["ami"] == "ami-6d1c2007"
          override.ssh.username = "centos"
        else
          override.ssh.username = "ec2-user"
        end

        if node["subnet_id"]
          aws.subnet_id = node["subnet_id"]
        else
          aws.security_groups = [ node['secgroup_name'] ]
        end
        if node["type"]
          aws.instance_type = node["type"]
        else
          aws.instance_type = "t2.micro"
        end
        aws.tags = {
            'Name' => node["name"],
        }
      end
      config.vm.synced_folder './', '/vagrant'
      #config.vm.provision :shell, inline: "apt-get update"

      unless node['folders'].nil?
        node['folders'].each do |folder|
          node_config.vm.synced_folder folder['local'], folder['virtual']
        end
      end

      unless node["initScript"].nil?
        node["initScript"].each do |script|
          node_config.vm.provision :shell, path: script["init"], privileged: true
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
  config.vm.provision :docker_compose, yml: ["/vagrant/docker-compose.yml"], rebuild: true, project_name: "minecraft", run: "always"


end

