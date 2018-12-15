# Overview
DevOps Architects provide reusable application templates.  This is a highly customizable vagrant solution which 
automates multiple technologies using a user-defined scenario w/ yaml.  It allows one or many assets to be 
created and leverages the best-of-class solutions OpenSource DevOps tooling to create, initialize, provision,
and modify a variety of virtual assets such as cloud-init, EC2 instances, docker, puppet, ruby, docker-compose, 
& chocolately.   

# SecDevOps Workflow 

To setup 1-or-Many machines in AWS:
   1) initialize the aws.template.yaml file w/:
        aws keys, docker registry info, & a filename for the instance definitions
   2) Fill-out the instance definition(s) 
```
- name:                 'asset name'
  ami: 	                'ami-3267bb24'
  user:                 'ubuntu'
  region:               'us-east-1'
  subnet_id:            'subnet-xxxxxxx'
  secgroup_name:        'sg-zzzzzz'
  aws_keypair_name:     'aws_vagrant_bootstrap'
  type:                 't2.medium'
  userData:             'cloud-init/initialize_ubuntu.txt'
```   
   3) Execute Vagrant up:
   first run will install the dependent plugins
   4) vagrant up again to create the assets
   5) Sitback and watch the instance get provisioned,
   6) Cloud-Init scripts get executed after bootup 
   7) Shared folders sync after cloud-init
     a. cloud-init
     b. shell-> update env, install packages, ruby, puppet
     c. execute provisioners -> docker, puppet, docker-compose
   8) Then Login `vagrant ssh <asset name>`