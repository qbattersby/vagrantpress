module Vagrant
  module Action

    class Up
      def initialize(app, env)
        @app = app
        @machine = env[:machine]
        @ips = nil
      end

      def call(env)
        if @machine.config.dnsmasq.enabled?
          env[:ui].info "Dnsmasq handler actived"

          @ip = @machine.config.dnsmasq.ip

          # is a proc?
          if @ip.is_a? Proc
            ips = @ip.call(@machine)
            ips = [ips] unless ips.is_a? Array
            ips.map!{|ip| begin Ip.new(ip) rescue nil end}.compact! # dismiss invalid ips
            @ip = ips
          end
          
          if @ip.is_a?(Array) && @ip.count > 0
            # @ip is an array with domain instances ...

            if @ip.count > 1
              # prompt: choose ip
              ask = true
              while(ask)
                env[:ui].info "Dnsmasq handler asks: Which IP would you like to use?"
                i = 0
                @ip.each do |ip|
                  i += 1
                  env[:ui].info "(#{i}) #{ip.v4}"
                end
                env[:ui].info "Please type number [1-#{i}]: "
                answer = $stdin.gets.strip.to_i - 1
                use_ip = @ip.at(answer)
                ask = false unless use_ip.nil? 
              end

            else
              use_ip = @ip[0]
            end

            # use ip to update dnsmasq.conf and /etc/resolver

            # fetch all domains to register from shared_projects
            domains = []
            Dir["projects/*"].each do |dir|
              dir = File.basename(dir)
              unless /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/.match(dir)

                name = dir.split('.')[0]
                domain = dir.gsub(name, "")
                domains << Domain.new(domain) if !domain.nil? && domain != '' && !domain.include?(" ")
              end
            end
            domains.uniq!

            # update dnsmasq.conf
            dnsmasq = DnsmasqConf.new('my.conf/dnsmasq/dnsmasq.conf')
            domains.each do |domain|
              puts "Registered domain: #{domain}"
              dnsmasq.insert(domain, use_ip)
            end
            
            # update /etc/resolver
            resolver = Resolver.new(@machine.config.dnsmasq.resolver, true) # true for sudo

            domains.each do |domain|
              puts "Resolver added domain: #{domain}"
              # resolver.insert(domain, Ip.new('192.168.192.168'))
              resolver.insert(domain, use_ip)
            end
            

            env[:ui].success "Dnsmasq handler set IP '#{use_ip}' for domain '#{@machine.config.dnsmasq.domain.dotted}'"

          else
            env[:ui].warn "Dnsmasq handler was not able to determine an IP address"
          end

          @app.call(env)
        end
      end
    end
  

    class Destroy
      def initialize(app, env)
        @app = app
        @machine = env[:machine]
      end

      def call(env)
        if @machine.config.dnsmasq.enabled?


          # fetch all domains to register from shared_projects
          domains = []
          Dir["projects/*"].each do |dir|
            dir = File.basename(dir)
            unless /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/.match(dir)

              name = dir.split('.')[0]
              domain = dir.gsub(name, "")
              domains << Domain.new(domain) if !domain.nil? && domain != '' && !domain.include?(" ")
            end
          end
          domains.uniq!


          unless @machine.config.dnsmasq.keep_resolver_on_destroy          
          # remove records from dnsmasq.conf and /etc/resolver

            # update dnsmasq.conf
            dnsmasq = DnsmasqConf.new('my.conf/dnsmasq/dnsmasq.conf')
            domains.each do |domain|
              dnsmasq.delete(domain)
            end

          # update /etc/resolver
          
            resolver = Resolver.new(@machine.config.dnsmasq.resolver, true) # true for sudo
            domains.each do |domain|
              resolver.delete(domain)
            end

          end

          env[:ui].success "Dnsmasq handler removed domain '#{@machine.config.dnsmasq.domain}'"

          @app.call(env)
        end
      end
    end

  end
end