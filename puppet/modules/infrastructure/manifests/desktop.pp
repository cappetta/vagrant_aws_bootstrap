# at some point make a new module named infrastructure
class infrastructure::desktop {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

# todo: create base profile for tools (nmap, tcpdump, htop, jq )
  $packages = [ 'vim-enhanced.x86_64', 'gedit', 'nmap','tcpdump', 'git', 'unzip', 'wget', 'gcc', 'htop', 'gmp-devel', 'postgresql-devel' ]
  package{ $packages: ensure => 'installed', }


  exec { 'set hostname':
      command => "echo desktop > /etc/hostname",
  }

  file_line { 'Setup Domain':
      line => 'kernel.domainname=minecraft.lab',
      path => '/etc/sysctl.conf'
  }

  file_line { 'DNS Server 1 ':
      line => 'namespace 8.8.8.8',
      path => '/etc/resolv.conf'
  }

  file_line { 'DNS Server 2 ':
      line => 'namespace 8.8.4.4',
      path => '/etc/resolv.conf'
  }

  if ! defined(Package['puppet-lint']) {
    package { 'puppet-lint':
        ensure   => '1.1.0',
        provider => 'gem',
    }
  }

  exec { 'Install Gnome Desktop':
      command => 'yum -y groups install "GNOME Desktop"',
      notify  => Exec['Update StartX Config'],
      timeout => 1800,
  }

  exec { 'Update StartX Config':
      command => "systemctl set-default graphical.target",
  }
  exec { 'Download Desktop Image #1':
    command => 'wget -O /usr/share/backgrounds/linux_1.jpg http://p1.pichost.me/i/11/1342999.jpg',
    notify  => Exec['setup desktop background']
  }

  exec {'setup desktop background':
      command => '/usr/bin/gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/linux_1.jpg'
  }


}