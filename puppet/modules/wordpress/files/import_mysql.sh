#!/bin/bash

# ---------------------------------------------
# a helper to import mysql databases and tables
# it will drop existing database
# it will drop existing table only (when used with option -t)
# please refer to according sql files, they contain the actual DROP statement
#
# takes user and password from ~/.my.cnf
# 
# ./import_mysql.sh -p path -d database (-t table_name)
#
# examples:
# ./import_mysql.sh -p /shared_projects/wptest.wp -d wptest
# ./import_mysql.sh -p /shared_projects/wptest.wp -d wptest -t user

printf "[Importing MySQL] "

if (($# == 0)); then
  printf "Usage: %s -p path -d database (-t table_name)\n" `basename $0` 
  exit 1
fi

# set default values
path=""
database=""
table=""

while getopts ":p:d:t:" opt; do
  case $opt in
    p)
      path=$OPTARG
      ;;
    d)
      database=$OPTARG
      ;;    
    t)
      table=$OPTARG
      ;;    
    \?)
      printf "Invalid option: -$OPTARG\n" >&2
      ;;
  esac
done

path=${path%/} # remove trailing slash

# path exists?
if [[ $path == "" || ! -d $path ]]; then
  printf "Path '%s' not found.\n" $path
  exit 1
fi

# database name given?
if [[ $database == '' ]]; then
  printf "Please specify database name.\n"
  exit 1
fi

# change directory
cd $path

# table?
if [[ $table != '' ]]; then

  # import table only
  # -----------------

  # .mysql/table/table.sql file exists?
  if [[ ! -f .mysql/tables/$table.sql ]]; then
    printf "'%s.sql' not found in '%s/.mysql/tables'.\n" $table $path
    exit 1
  fi

  # database exists?
  if ! mysqlshow "$database" >/dev/null 2>&1; then 
    printf "Database '%s' not found, cannot import table '%s'.\n" \
      $database $table    
    exit 1
  fi

  # import table (import should contain drop statement)
  printf "Table '%s' into database '%s'." $table $database

  mysql $database < .mysql/tables/$table.sql

  printf " Done.\n"

else

  # import database
  # ---------------

  # verify .mysql/database.sql exist
  if [[ ! -f .mysql/database.sql ]]; then
    printf "'database.sql' not found in '%s.mysql'.\n" $path
    exit 1
  fi

  printf "Database '%s'." $database

  mysql < .mysql/database.sql

  printf " Done.\n"

fi
