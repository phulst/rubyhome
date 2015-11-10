# All device controllers should extend from this class
module RubyHome
  module Controllers
    class DeviceController

      def devices
        @devices ||= []
      end

      # adds a device for this controller. Also set the controller attribute on device
      def add_device(device)
        if !devices.include?(device)
          devices << device
          device.controller = self
        end
      end
    end
  end
end
