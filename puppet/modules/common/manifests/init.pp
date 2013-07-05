class common::install{
  package{"git-core": ensure=>present,}
  package{"curl": ensure=>present,}
  package{"wget": ensure=>present,}
  package{"imagemagick": ensure=>present,}
  package{"unzip": ensure=>present,}
  package{"vim": ensure=>present,}
  package{"build-essential": ensure=>present,}
  package{"libmysqlclient-dev": ensure=>present,}


  # https://github.com/brianmario/mysql2
  package { 'mysql2':
      ensure   => 'latest',
      provider => 'gem',
      require => Package["libmysqlclient-dev"],
  }

}


