class mysql::install {
  $password = "vagrant"


  package { "mysql-client": ensure => installed }
  package { "mysql-server": ensure => installed }

 # service { "mysql":
 #    enable => true,
 #    ensure => running,
 #    require => Package["mysql-server"],
 #  }

  exec { "Set MySQL server root password and allow remote access for root":
    subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
    refreshonly => true,
    unless => "mysqladmin -uroot -p$password status",
    path => "/bin:/usr/bin",
    command => "mysqladmin -uroot password $password; mysql --user='root' --password='vagrant' -e \"CREATE USER 'root' IDENTIFIED BY 'vagrant'; GRANT ALL ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;\"",
  }

  file { "/etc/mysql/my.cnf":
      ensure => link,
      source => "puppet:///modules/mysql/mysql-my.cnf",
      require => Package['mysql-server'],
      # notify  => Service["mysql"],
  }


  # use this file with user and password credentials
  file { "/home/vagrant/.my.cnf":
      ensure => link,
      source => "puppet:///modules/mysql/home-my.cnf",
      require => Package['mysql-server'],
      owner => "vagrant",
      mode => "600",
  }

}
