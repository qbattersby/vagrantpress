class mysql::install {
  $password = "vagrant"
  package { "mysql-client": ensure => installed }
  package { "mysql-server": ensure => installed }

  exec { "Set MySQL server root password":
    subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
    refreshonly => true,
    unless => "mysqladmin -uroot -p$password status",
    path => "/bin:/usr/bin",
    command => "mysqladmin -uroot password $password",
  }

  # exec { "Grant MySQL server remote access":
  #   subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
  #   refreshonly => true,
  #   command => "mysql --user='root' --password='vagrant' --host='localhost' --skip-column-names -e \"SET PASSWORD FOR 'root'@'localhost' = PASSWORD('vagrant'); SET PASSWORD FOR 'root'@'%' = PASSWORD('vagrant'); GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION; FLUSH PRIVILEGES;\"",
  #   require => Exec["Set MySQL server root password"],
  # }

}
