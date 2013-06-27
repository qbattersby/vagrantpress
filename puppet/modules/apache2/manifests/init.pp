class apache2::install{

  package { "apache2": ensure => present,}

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }

  # use our httpd.conf file
  file { "/etc/apache2/conf.d/httpd.conf":
      ensure => file,
      source => "puppet:///modules/apache/httpd.conf",
      require => Package['apache2'],
      notify  => Service["apache2"],
  }

}
