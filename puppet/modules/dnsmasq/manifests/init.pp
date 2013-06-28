class dnsmasq::install {

  package { "dnsmasq": ensure => latest,}

  service { "dnsmasq":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus  => true,
    require => Package["dnsmasq"],
  }

  # symlink dnsmasq.conf
  file { "/etc/dnsmasq.conf":
      ensure => link,
      source => "puppet:///modules/dnsmasq/dnsmasq.conf",
      require => Package['dnsmasq'],
      notify  => Service["dnsmasq"],
  }

  # symlink user dnsmasq.conf
  #   file { "/etc/my.dnsmasq.conf":
  #       ensure => link,
  #       source => "/my.conf/dnsmasq/dnsmasq.conf",
  #       require => Package['dnsmasq'],
  #       notify  => Service["dnsmasq"],
  #   }

}