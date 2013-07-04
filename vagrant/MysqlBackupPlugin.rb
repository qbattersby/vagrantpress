
module MysqlBackup

  require 'pathname'

  class Import

    def initialize(app, env)
      @app = app
      @machine = env[:machine]
    end

    def call(env)
      Dir["projects/*"].each do |dir|
        dir = Pathname.new(dir).expand_path
        # find wp-config.php
        wp_config_file = (dir + "wp-config.php")
        if wp_config_file.exist?
          wp_config = IO.read(wp_config_file)
            .match(/define\('DB_NAME', '(.*)'\);/)
          database_name = wp_config[1]
          
          system "vagrant ssh -c \"./import_mysql.sh \
            -p /shared_projects/#{dir.basename} -d #{database_name}\""
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

      Dir["projects/*"].each do |dir|
        dir = Pathname.new(dir).expand_path
        # find wp-config.php
        wp_config_file = (dir + "wp-config.php")
        if wp_config_file.exist?
          wp_config = IO.read(wp_config_file)
            .match(/define\('DB_NAME', '(.*)'\);/)
          database_name = wp_config[1]
          
          system "vagrant ssh -c \"./export_mysql.sh \
            -p /shared_projects/#{dir.basename} -d #{database_name}\""
        end
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

  # action_hook(:mysql_backup, :machine_action_reload) do |hook|
  #   hook.append(MysqlBackup::Import)
  # end

  action_hook(:mysql_backup, :machine_action_destroy) do |hook|
    hook.prepend(MysqlBackup::Export)
  end

  # action_hook(:mysql_backup, :machine_action_halt) do |hook|
  #   hook.prepend(MysqlBackup::Export)
  # end
end