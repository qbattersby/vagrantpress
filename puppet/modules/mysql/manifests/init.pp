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

  # use our httpd.conf file
  file { "/etc/mysql/my.cnf":
      ensure => link,
      source => "puppet:///modules/mysql/mysql-my.cnf",
      require => Package['mysql-server'],
      # notify  => Service["mysql"],
  }

  # exec { "Grant MySQL server remote access":
  #   subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
  #   refreshonly => true,
  #   command => "mysql --user='root' --password='vagrant' --host='localhost' --skip-column-names -e \"SET PASSWORD FOR 'root'@'localhost' = PASSWORD('vagrant'); SET PASSWORD FOR 'root'@'%' = PASSWORD('vagrant'); GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION; FLUSH PRIVILEGES;\"",
  #   require => Exec["Set MySQL server root password"],
  # }

}
