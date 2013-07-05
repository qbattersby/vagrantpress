class WPCLI_Wrapper < Vagrant.plugin("2")
  name "WP-CLI Wrapper"

  command "wp" do

    # run commands like
    # vagrant wp wordpress_dir core download

    class WpCommand < Vagrant.plugin('2', :command)

      def execute
        cmds = ARGV
        wordpress_dir = cmds.shift && cmds.shift
        system "vagrant ssh -c \"cd /shared_projects/#{wordpress_dir} && \
          wp #{cmds.join(" ")}\""
      end
    end
    WpCommand

  end

end
