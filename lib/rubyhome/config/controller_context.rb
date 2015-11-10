
module RubyHome
  module Config
    class ControllerContext
      attr_accessor :controllers

      def initialize
        @controllers = []
      end

      # return the default controller
      def default_controller
        @controllers[0] if !@controllers.empty?
      end

      # adds and instantiates the controller
      def add_controller(name, *args)
        controller = { type: name, address: args.shift }.merge(@current_options)
        controller.merge!(args[0]) if (args.length > 0 && args[0].is_a?(Hash))
        @controllers << controller
      end

      # receives options and evaluates block in current context
      def evaluate(options, &block)
        @current_options = options
        instance_eval(&block)
      end

      def method_missing(method, *args)
        add_controller(method, *args)
      end
    end
  end
end
