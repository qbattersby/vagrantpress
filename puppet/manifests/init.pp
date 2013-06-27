# use paths for Exec statements
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# virtual resource
@exec { 'sudo apt-get update':
   tag => update
}

# realize resource. filter by "update" tag
# and relate it to all Package resources
Exec <| tag == update |> -> Package <| |>


node default {

  class { 'git::install': }
  class { 'apache2::install': }
  class { 'php5::install': }  
  class { 'mysql::install': }
  
  # class{'wordpress::install':}
  # use wp-cli instead?
  # https://github.com/wp-cli/wp-cli
}