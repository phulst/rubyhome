require 'rubyhome/errors/errors'

# processes light configurations and stores these in the :lights hash
#
module RubyHome
  module Config
    class LightsContext
      attr_accessor :lights

      def initialize
        @lights = {}
      end

      # receives options and evaluates block in current context
      def evaluate(options, &block)
        instance_eval(&block)
      end

      def add_light(name, *args)
        # make sure address is specified
        address = args.shift
        raise RubyHome::ConfigError, "a light with address #{address} has already been defined" if !@lights.select{|k,v| v[:address] == address}.empty?
        raise RubyHome::ConfigError, "missing address for light '#{name}'" if !address
        raise RubyHome::ConfigError, "light with name ''#{name}' already exists. You should only define it once!" if @lights[name]

        light = { name: name, address: address }.merge(@current_options)
        light.merge!(args[0]) if (args.length > 0 && args[0].is_a?(Hash))

        @lights[light[:name]] = light
      end

      # receives options and evaluates block in current context
      def evaluate(options, &block)
        @current_options = options
        instance_eval(&block)
      end

      def method_missing(method, *args)
        add_light(method, *args)
      end
    end
  end
end