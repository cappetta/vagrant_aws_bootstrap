# at some point make a new module named infrastructure
class infrastructure::ubuntu-minecraft-desktop {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

# todo: create base profile for tools (nmap, tcpdump, htop, jq )
  $packages = [ 'vim', 'gedit', 'nmap','tcpdump', 'git', 'unzip', 'wget', 'gcc', 'htop','xinit','gsettings-ubuntu-schemas', 'terminator', 'openjdk-7-jdk']

  package{ $packages: 
    ensure => 'installed',
    notify => Exec['Update & Install Gnome Desktop'],
   }


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

  exec { 'Update & Install Gnome Desktop':
      command => 'apt-get update && apt-get install -y ubuntu-gnome-desktop',
      notify  => Exec['StartX Server'],
      timeout => 1800,
  }

  exec { 'StartX Server':
      command => "startx"
  }

  file { '/usr/share/backgrounds/':
    ensure => directory
  }->
  exec { 'Download Desktop Image #1':
    command => 'wget -O /usr/share/backgrounds/linux_1.jpg http://p1.pichost.me/i/11/1342999.jpg',
  # notify  => Exec['setup desktop background'],
    
  }

  #exec {'setup desktop background':
  #    command => 'gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/linux_1.jpg'
  #}

  file {'/home/vagrant/Desktop':
    ensure => directory,
    notify => Exec['Download Minecraft']
    }

  exec { 'Download Minecraft':
    command => 'wget -O /home/vagrant/Desktop/minecraft.jar http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar',
    notify  => File['/home/vagrant/Desktop/minecraft.jar'],
  }

  file {'/home/vagrant/Desktop/minecraft.jar':
    ensure => 'present',
    mode   => '0755',
  }



}