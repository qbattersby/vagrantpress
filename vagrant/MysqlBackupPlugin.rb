# THIS FILE IS A COMPLETE MESS!!!!
# IT NEEDS A LOT OF REFACTORING

# WHAT IT DOES: 
# adding hooks: machine_action_up, machine_action_reload and machine_action_destroy
# vagrant up will create databases and import .mysql_dumps.sql if no database is created
#  with config from wp-config.php
# vagrant reload (see above)
# vagrant destroy will dump databases and save them to .mysql_dumps.sql
#
#
#
#
#


class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end


require 'open3'
class System2

  attr_reader :exit_code, :out, :err, :in, :cmd_string, :vagrant_wrapper

  def initialize(cmd_string, vagrant_wrapper = true, run_now = true)
    @cmd_string = cmd_string
    @vagrant_wrapper = true if vagrant_wrapper
    @ok = nil
    @exit_code = nil
    @out = nil
    @err = nil
    @in = nil

    run if run_now
  end

  def run
    begin
      @cmd_string = "vagrant ssh -c \"#{@cmd_string}\"" if @vagrant_wrapper
      Open3.popen3(@cmd_string) do |stdin, stdout, stderr, thr|
        @ok = thr.value.to_i == 0 ? true : false
        @exit_code = thr.value.to_i
        @out = stdout.read.to_s.strip
        @err = stderr.read.to_s.strip
        @in = stdin
      end 
    rescue
      @ok = false
    end
    return self
  end

  def log
    puts(@cmd_string)
    return self
  end

  def rife # alias
    raise_if_error
  end

  def raise_if_error
    raise RuntimeError, "'#{@cmd_string}' returned '#{@err}'" unless ok?
    return self
  end

  def ok?
    @ok
  end

  def errout
    @out << @err
  end
end


class Mysql

  attr_reader :user, :password, :host

  def initialize(config)
    @user = nil
    @password = nil
    @host = nil
    set_config(config) if config
  end

  def set_config(config)
    if config.is_a? Mysql
      @user = config.user
      @password = config.password
      @host = config.host
      return
    end

    @user = config['user'] || config[:user]
    @password = config['password'] || config[:password]
    @host = config['host'] || config[:host] # includes port

    raise ArgumentError, 'nil user' if @user.blank?
    raise ArgumentError, 'nil password' if @password.blank?
    raise ArgumentError, 'nil host' if @host.blank?
  end

# cmd = System2.new(MysqlBackup::vagrant_ssh_wrapper("mysql --password='vagrant' --user='root' --host='localhost' --skip-column-names -e 'SHOW DATABASES LIKE \\\"#{db_name}\\\"'")).rife

  # verify login data
  def ok?
    result = nil
    with_password_file do |pw_file|
      # cmd = System2.new("mysql --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' -e 'SELECT \"i am logged in\"'")
      cmd = System2.new("mysql --password='#{@password}' --user='#{@user}' --host='#{@host}' -e 'SELECT \\\"i am logged in\\\"'")
      if cmd.ok?
        result = cmd.out.scan('i am logged in').count > 0
      else
        result = false
      end
    end
    return result
  end

  def database_exists?(name)
    result = nil
    with_password_file do |pw_file|
      # cmd = System2.new("mysql --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' --skip-column-names -e \"SHOW DATABASES LIKE '#{name}'\"")
      cmd = System2.new("mysql --password='#{@password}' --user='#{@user}' --host='#{@host}' --skip-column-names -e 'SHOW DATABASES LIKE \\\"#{name}\\\"'")
      if cmd.ok?
        result = cmd.out.scan("#{name}").count >= 1
      else
        result = false
      end
    end
    return result
  end

  def create_database!(name)
    result = false
    with_password_file do |pw_file|
      # result = System2.new("mysqladmin --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' create #{name}").rife.ok?
      result = System2.new("mysqladmin --password='#{@password}' --user='#{@user}' --host='#{@host}' create #{name}").rife.ok?
    end
    return result
  end

  def delete_database!(name)
    result = false
    if database_exists?(name)
      with_password_file do |pw_file|
        # result = System2.new("mysqladmin --defaults-file='#{pw_file}' --force --user='#{@user}' --host='#{@host}' drop #{name}").rife.ok?
        result = System2.new("mysqladmin --password='#{@password}' --force --user='#{@user}' --host='#{@host}' drop #{name}").rife.ok?
      end
    end
    return result
  end

  def query(name, query, return_out = false, skip_column_names = false)
    raise ArgumentError, "database #{name} does not exist" unless database_exists?(name)
    result = nil
    with_password_file do |pw_file|
      # cmd = System2.new("mysql --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' #{'--skip-column-names' if skip_column_names} -e \"USE #{name}; #{query}\"").rife
      cmd = System2.new("mysql --password='#{@password}' --user='#{@user}' --host='#{@host}' #{'--skip-column-names' if skip_column_names} -e 'USE #{name}; #{query}'").rife
      if cmd.ok?
        result = return_out ? cmd.out : true
      else
        result = false
      end
    end
    return result
  end

  def list_tables(database_name)
    result = query(database_name, "SHOW TABLES FROM #{database_name}", true, true)
    tables = result.split("\n")
    return tables
  end

  # specifiy table to dump table in database only
  def dump_database(name, filename, table = nil)
    raise ArgumentError, "database #{name} does not exist" unless database_exists?(name)

    if File.exists? filename
      System2.new("rm #{filename}").rife
    else
      System2.new("mkdir -p #{File.dirname(filename)}").rife unless Dir.exists?(File.dirname(filename))
    end
    
    with_password_file do |pw_file|
      # System2.new("mysqldump --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' --result-file='#{filename}' #{name} #{table unless table.blank?}").rife
      System2.new("mysqldump --password='#{@password}' --user='#{@user}' --host='#{@host}' --result-file='#{filename}' #{name} #{table unless table.blank?}").rife
    end
  end

  # filename can be path to full database dump or table dump
  def reset_database(name, filename, table = nil)
    raise ArgumentError, "database #{name} does not exist" unless database_exists?(name)

    if table.nil?
      # create empty database
      delete_database!(name)
      create_database!(name)
    else 
      # drop table
      query(name, "DROP TABLE IF EXISTS #{table};")
    end

    with_password_file do |pw_file|
      # System2.new("mysql --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' #{name} < #{filename}").rife
      System2.new("mysql --password='#{@password}' --user='#{@user}' --host='#{@host}' #{name} < #{filename}").rife
    end
  end

  # filename can be path to full database dump or table dump
  def create_database_with_file(name, filename)
    create_database!(name)
    with_password_file do |pw_file|
      # System2.new("mysql --defaults-file='#{pw_file}' --user='#{@user}' --host='#{@host}' #{name} < #{filename}").rife
      System2.new("mysql --password='#{@password}' --user='#{@user}' --host='#{@host}' #{name} < #{filename}").rife
    end
  end


  def to_s
    "#{!@user.blank? ? @user : '<empty_user>'}:#{!@password.blank? ? @password : '<empty_password>'}@#{!@host.blank? ? @host : '<empty_host>'}"
  end


  private

  def with_password_file(&block)
    # see http://dev.mysql.com/doc/refman/5.1/en/password-security-user.html
    # random = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    # password_filename = "/tmp/wordpress-util-mysql-#{random}"
 
    # content  = "[client]\n"
    # content += "password=#{@password}\n"

    # # create file contents
    # File.open(password_filename, 'w', 0400) { |file|
    #   file.write content
    # }
 
    # # do mysql call or whatever
    password_filename = nil
    block.call(password_filename)

    # File.delete password_filename
  end

end





module MysqlBackup


  class Import
    def initialize(app, env)
      @app = app
      @machine = env[:machine]
    end
    def call(env)
      puts "MysqlBackup import"

      # @todo

      # find all wp-config.php files in projects/*
      dir_name = File.absolute_path('projects')

      # find all wp-config.php files in projects/*
      wordpress_dirs = []
      Dir["#{dir_name}/*"].each do |dir|
        wordpress_dirs << dir if File.exists?("#{dir}/wp-config.php")
      end

      # dump mysql data for database
      wordpress_dirs.each do |dir|
        # unless database for project exists, create database and import .mysql_dump

        wp_config = IO.read("#{dir}/wp-config.php")
        db_name = wp_config.scan(/define\('DB_NAME', '(.*)?'\);/)[0][0]
        db_user = wp_config.scan(/define\('DB_USER', '(.*)?'\);/)[0][0]
        db_pass = wp_config.scan(/define\('DB_PASSWORD', '(.*)?'\);/)[0][0]
        db_host = wp_config.scan(/define\('DB_HOST', '(.*)?'\);/)[0][0]

        result_file = "#{dir}/.mysql_dump.sql"
        result_file_at_guest = "/shared_projects/#{File.basename(dir)}/.mysql_dump.sql"

        mysql = Mysql.new({:user => db_user, :password => db_pass, :host => db_host})
        raise "Invalid mysql #{mysql}" unless mysql.ok?

        unless mysql.database_exists?(db_name)
          if File.exists?(result_file)
            puts "Mysql Database Import: #{db_name}"
            mysql.create_database_with_file(db_name, result_file_at_guest)
          else
            puts "MySQL IMPORT FAILED: missing #{result_file}"
          end
        end


      end

      @app.call(env)
    end
  end

  class Export
    def initialize(app, env)
      @app = app
      @machine = env[:machine]
    end
    def call(env)
      puts "MysqlBackup export"

      # @todo
      dir_name = File.absolute_path('projects')

      # find all wp-config.php files in projects/*
      wordpress_dirs = []
      Dir["#{dir_name}/*"].each do |dir|
        wordpress_dirs << dir if File.exists?("#{dir}/wp-config.php")
      end

      # dump mysql data for database
      wordpress_dirs.each do |dir|

        wp_config = IO.read("#{dir}/wp-config.php")
        db_name = wp_config.scan(/define\('DB_NAME', '(.*)?'\);/)[0][0]
        db_user = wp_config.scan(/define\('DB_USER', '(.*)?'\);/)[0][0]
        db_pass = wp_config.scan(/define\('DB_PASSWORD', '(.*)?'\);/)[0][0]
        db_host = wp_config.scan(/define\('DB_HOST', '(.*)?'\);/)[0][0]

        result_file = "/shared_projects/#{File.basename(dir)}/.mysql_dump.sql"

        mysql = Mysql.new({:user => db_user, :password => db_pass, :host => db_host})
        raise "Invalid mysql #{mysql}" unless mysql.ok?

        # save dump to projects/foobar/.mysql_dump
        #MysqlBackup::with_password_file do |pw_file|
          puts "Mysql Database Export: #{db_name}"

          if mysql.database_exists?(db_name)
            mysql.dump_database(db_name, result_file)
            # System2.new("mysqldump --password='vagrant' --user='#{db_user}' --host='#{db_host}' --result-file='#{result_file}' #{db_name}").rife
          else
            puts "FAILED: '#{db_name}' does not exist for #{mysql}"
          end
        # end

      end

      @app.call(env)
    end

  end

end


class MysqlBackupPlugin < Vagrant.plugin("2")
  name "Mysql Backup"

  action_hook(:mysql_backup, :machine_action_up) do |hook|
    hook.append(MysqlBackup::Import)
  end

  action_hook(:mysql_backup, :machine_action_reload) do |hook|
    hook.append(MysqlBackup::Import)
  end

  action_hook(:mysql_backup, :machine_action_destroy) do |hook|
    hook.prepend(MysqlBackup::Export)
  end

  action_hook(:mysql_backup, :machine_action_halt) do |hook|
    hook.prepend(MysqlBackup::Export)
  end
end