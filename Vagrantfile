# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure(2) do |config|

  config.vm.box = "dummy"
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


    nodes.each do |node|
      config.vm.define node["name"] do |node_config|
        node_config.vm.box = node["box"]

        node["forwards"].each do |port|
          node_config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], id: port["id"]
        end

        unless node['folders'].nil?
          node['folders'].each do |folder|
            node_config.vm.synced_folder folder['local'], folder['virtual']
          end
        end

        config.vm.provider :aws do |aws, override|
          aws.access_key_id = creds[""]
          aws.secret_access_key = creds[""]
          aws.session_token =
          aws.keypair_name = [""]

          aws.ami = "ami-7747d01e"

          override.ssh.username = "ubuntu"
          override.ssh.private_key_path = "PATH TO YOUR PRIVATE KEY"
        end
        #config.vbguest.iso_path = 'http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso'
        #config.vbguest.auto_update = true

        config.vm.synced_folder './', '/vagrant'
        #config.vm.provision :shell, inline: "apt-get update"
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


end
