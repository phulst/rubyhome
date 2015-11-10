require 'open-uri'
require 'json'
require 'nats/client'

module ISY
  class Controller

    attr_reader :options, :name

    # constructor
  	def initialize(host, opts = {})
      @host = host

  	  defaults = {} # no defaults yet
  	  @options = defaults.merge(opts)

      @name = @options[:name] || 'isy'
      puts "instantiating controller with address: #{host} and name #{@name}"
  	  raise "you must set the ISY hostname" if host.nil? || host.strip.length == 0

      # subscribe to command messages on the bus with a matching queue name
      NATS.subscribe("#{queue_name}.cmd.*") do |msg, reply, sub|
        data = JSON.parse(msg)
        send_command(data['address'], data['cmd'].to_sym)
        #puts "controller received command for #{sub}: #{data['address']}"
      end
  	end

    def queue_name
      @name.gsub(/[^a-zA-Z0-9]/, '')
    end

    def send_command(address, command)
      # TODO: send command
    end

    private

    # transmit the command string to the ISY device
  	def transmit_command(command_str)
  	  puts "sending command #{command_str}"
  	  cmd_url = "http://#{@host}/3?#{command_str}=I=3"
      open cmd_url do |f|
        puts f.read
      end
   end	

  end
end