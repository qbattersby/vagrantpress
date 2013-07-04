#!/bin/bash

# ---------------------------------------------
# a helper to export mysql databases and tables
# takes user and password from ~/.my.cnf
# 
# ./export_mysql.sh -p path -d database (-t with tables)
#
# examples:
# ./export_mysql.sh -p /shared_projects/wptest.wp -d wptest
# ./export_mysql.sh -p /shared_projects/wptest.wp -d wptest -t


printf "[Exporting MySQL] "

if (($# == 0)); then
  printf "Usage: %s -p path -d database (-t with tables)\n" `basename $0` 
  exit 1
fi

# set default values
path=""
database=""
with_tables=false

while getopts ":p:d:t" opt; do
  case $opt in
    p)
      path=$OPTARG
      ;;
    d)
      database=$OPTARG
      ;;    
    t)
      with_tables=true
      ;;    
    \?)
      printf "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

path=${path%/} # remove trailing slash

# path exists?
if [[ $path == "" || ! -d $path ]]; then
  printf "Path '%s' not found.\n" $path
  exit 1
fi

# database exists?
if ! mysqlshow "$database" >/dev/null 2>&1; then 
  printf "Database '%s' not found.\n" $database  
  exit 1
fi

# change directory
cd $path

# .mysql dir exists?
if [[ ! -d .mysql ]]; then
  mkdir .mysql
fi

# start export
printf "Database '%s' into '%s/.mysql/database.sql'" $database $path
mysqldump --add-drop-database --databases $database > .mysql/database.sql

# export as separate tables as well?
if [[ $with_tables == true ]]; then
  printf ' and tables into %s/.mysql/tables/*.sql' \
    $database

  # .mysql/tables dir exists?
  if [[ ! -d .mysql/tables ]]; then
    mkdir .mysql/tables
  fi

  for _table in $(mysql $database --batch --skip-column-names -e 'show tables'); do
    mysqldump --add-drop-table $database $_table > ".mysql/tables/$_table.sql"
  done

  # has some permission issues ... so, using the code from above
  # mysqldump --tab=".mysql/tables" --add-drop-table $database
fi

printf ". Done.\n"
