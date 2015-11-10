require 'rubyhome/config/lights_context'
require 'rubyhome/config/controller_context'
require 'rubyhome/config/config_context'
require 'rubyhome/device/light'
require 'rubyhome/controllers/smart_linc/controller'

# processes configuration file
module RubyHome
  module Config
    class ConfigProcessor

      CONTROLLERS = { smart_linc: SmartLinc::Controller }

      def process(file)
        # evaluate the file within the context of this object
        device_file = File.join(File.dirname(__FILE__), "../../..", file, 'devices', 'device.rb')

        config_context = ConfigContext.new
        config_context.instance_eval(File.open(File.expand_path(device_file)).read, device_file)

        controllers = config_context.controller_context.controllers
        lights = config_context.lights_context.lights

        puts "Number of controllers added: #{controllers.length}"
        puts "Default controller: #{controllers[0]}"

        puts "\nControllers:"
        p config_context.controller_context.controllers
        init_controllers(config_context.controller_context.controllers)

        init_lights(config_context.lights_context.lights)
        puts "\nLights:"
        puts @lights.inspect


        #@lights[1].off
        ##sleep(3)
        #@lights[1].on

        [@controllers, @lights]
      end

      # takes an array of hashes with the controller configs, and instantiates all controller objects
      def init_controllers(controllers)
        @controllers = []
        controllers.each do |c|
          klass = c[:class_name] || CONTROLLERS[c[:type]]
          raise RubyHome::ConfigError, "unable to find class for controller: #{c.inspect}" if !klass
          controller = klass.new(c[:address], c)
          if c[:default] && @controllers.length > 0
            # add default controller as first element
            @controllers.insert(0, controller)
          else
            @controllers << controller
          end
        end
      end

      # receives hash of light configuration and instantiates all Light objects
      def init_lights(lights_config)
        @lights = []

        lights_config.each_pair do |name, options|
          address = options.delete(:address)
          light = RubyHome::Device::Light.new(name, address, options)

          @lights << light

          # add device to controller
          c = find_controller(options[:controller])
          raise RubyHome::ConfigError, "Light #{name} uses controller '#{options[:controller]}' but no controller with that name was defined" if !c
          light.controller_queue = c.queue_name
        end
      end

      # find the controller object with matching name, or return the default controller
      # if no name specified.
      def find_controller(name)
        return @controllers[0] if !name # return default controller
        @controllers.each do |controller|
          return controller if (controller.name == name)
        end
        nil # not found
      end
    end
  end
end

