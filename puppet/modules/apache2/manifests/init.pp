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

  # disable default site after fresh apache installation
  exec { "a2dissite 000-default":
     command => "a2dissite 000-default",
     onlyif => "test -f /etc/apache2/sites-enabled/000-default",
     require => Package["apache2"],
     notify  => Service["apache2"],
  }

  # enable mod vhost_alias
  exec { "a2enmod vhost_alias":
     command => "a2enmod vhost_alias",
     creates => '/etc/apache2/mods-enabled/vhost_alias.load',
     require => Package["apache2"],
     notify  => Service["apache2"],
  }

  # enable mod rewrite
  exec { "a2enmod rewrite":
      command => "a2enmod rewrite",
      creates => '/etc/apache2/mods-enabled/rewrite.load',
      require => Package["apache2"],
      notify  => Service["apache2"],
  }

}
