#$slave_home = "${::systemdrive}\\jenkins-slave"
$slave_home = "c:\\jenkins-slave"

file { $slave_home :
  ensure => directory,
}

file { "${slave_home}/jenkins-slave.exe":
  ensure => file,
  mode => '0777',
  #source => 'puppet:///modules/pup1389/jenkins-slave.exe',
  source => 'C:\vagrantshared\puppet\modules\pup1389\files\jenkins-slave.exe',
  source_permissions => ignore,
  require => File[$slave_home],
  backup => false,
}

# # ReplaceFileW results in no go
# file { "${slave_home}\\jenkins-slave.xml":
#   ensure => file,
#   content => template('pup1389/jenkins-slave.xml.erb'),
#   require => File[ $slave_home ],
#   backup => false,
# }

# # works
# file { "${slave_home}/jenkins-slavexml":
#   ensure => file,
#   content => template('pup1389/jenkins-slave.xml.erb'),
#   require => File[ $slave_home ],
#   backup => false,
# }

# # works
# file { "${slave_home}/jenkinsslave.xml":
#   ensure => file,
#   content => template('pup1389/jenkins-slave.xml.erb'),
#   require => File[ $slave_home ],
#   backup => false,
# }

# # works
# file { "${slave_home}/jenkins_slave.xml":
#   ensure => file,
#   content => template('pup1389/jenkins-slave.xml.erb'),
#   require => File[ $slave_home ],
#   backup => false,
# }

# file { "${slave_home}\\jenkins-slave.exe.config":
#   ensure => file,
#   content => template('pup1389/jenkins-slave.exe.config.erb'),
#   require => File[$slave_home],
#   backup => false,
# }
