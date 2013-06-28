class WPCLI_Wrapper < Vagrant.plugin("2")
  name "WP-CLI Wrapper"

  command "wp" do

    # run commands like
    # vagrant wp core download --path=/shared_projects/new345

    # @idea: vagrant wp cd /shared_projects/ changes directory, subsequent commands are done in
    # this directory then.

    class WpCommand < Vagrant.plugin('2', :command)

      def execute        
        cmds = ARGV
        system "vagrant ssh -c \"#{cmds.join(" ")}\""
      end
    end
    WpCommand

  end

end