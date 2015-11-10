require 'open-uri'
require 'json'
require 'nats/client'

require File.join(File.dirname(__FILE__), 'insteon.rb')
require File.join(File.dirname(__FILE__), 'x10.rb')

module SmartLinc
  class Controller
    include Insteon
    include X10

    attr_reader :options, :name

    # constructor
  	def initialize(host, opts = {})
      @host = host

  	  defaults = {} # no defaults yet
  	  @options = defaults.merge(opts)

      @name = @options[:name] || 'smart_linc'
      puts "instantiating controller with address: #{host} and name #{@name}"
  	  raise "you must set the SmartLinc hostname" if host.nil? || host.strip.length == 0

      # subscribe to command messages on the bus with a matching queue name
      NATS.subscribe("#{queue_name}.cmd.*") do |msg, reply, sub|
        data = JSON.parse(msg)
        send_command(data['address'], data['cmd'].to_sym)
        #puts "controller received command for #{sub}: #{data['address']}"
      end
  	end

    # sends a X10 command to the controller
    def send_x10_command(address, command)
      transmit_command(x10_command_string(address, command))
    end

    def queue_name
      @name.gsub(/[^a-zA-Z0-9]/, '')
    end

    # sends an insteon command to the controller
    def send_insteon_command(address, command)
      transmit_command(insteon_command_string(address, command))
    end

    def send_command(address, command)
      if x10_address?(address)
        send_x10_command(address, command)
      else
        send_insteon_command(address, command)
      end
    end

    # returns true if the given address is a X10 address
    def x10_address?(address)
      address =~ /[A-P](\d){1,2}/
    end

    private

    # transmit the command string to the SmartLinc device
  	def transmit_command(command_str)
  	  puts "sending command #{command_str}"
  	  cmd_url = "http://#{@host}/3?#{command_str}=I=3"
      open cmd_url do |f|
        puts f.read
      end
   end	

  end
end