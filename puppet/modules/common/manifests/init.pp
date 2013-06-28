class common::install{
  package{"git-core": ensure=>present,}
  package{"curl": ensure=>present,}
  package{"wget": ensure=>present,}
  package{"imagemagick": ensure=>present,}
  package{"unzip": ensure=>present,}
  package{"vim": ensure=>present,}
}
