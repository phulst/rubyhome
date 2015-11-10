require 'rubyhome/config/config_processor'
require 'rubyhome/executor/script_executor'
require "nats/client"

module RubyHome
  class HomeConfig

    def initialize(device_file)

      NATS.start do

        controllers, lights  = RubyHome::Config::ConfigProcessor.new.process(device_file)
        RubyHome::Scheduling.start_scheduler

        @executor = RubyHome::ScriptExecutor.new(controllers, lights)
        @executor.process(device_file)

        NATS.subscribe('>')  do |msg, reply, sub|
          puts "BUS (#{sub}) : #{msg}"
        end
      end


      #while(true)
      ##  sleep 1
      #end
    end
  end
end


