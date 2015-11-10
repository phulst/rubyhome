module RubyHome
  module Executor
    class DeviceCommand
      attr_accessor :command, :device

      def initialize(device, command)
        self.device = device
        self.command = command
      end
    end
  end
end