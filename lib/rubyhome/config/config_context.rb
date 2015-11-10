module RubyHome
  module Config
    class ConfigContext
      attr_reader :lights_context, :controller_context

      def initialize
        @lights_context = LightsContext.new
        @controller_context = ControllerContext.new
      end

      # add controllers
      def controllers(options = {}, &block)
        # execute block in controllercontext
        @controller_context.evaluate(options, &block)
      end

      def lights(options = {}, &block)
        # execute block in lights context
        @lights_context.evaluate(options, &block)
      end
    end
  end
end