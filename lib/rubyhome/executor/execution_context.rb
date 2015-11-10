require 'rubyhome/executor/device_command'
require 'rubyhome/device/light'
require 'rubyhome/scheduler/scheduling'

#
# user script are executed within the context of this object. Note that each script runs in it's own
# execution context, so currently you can't share variables between files (unless you use Ruby global variables)
#
class ExecutionContext
  include RubyHome::Scheduling

  # these, when called, are not actual methods but simple string literals
  LITERALS = %w{on off dim}

  # TODO, make controllers and lights available through external object, as opposed to passing it around
  def initialize(controllers, lights)
    #start_scheduler

    @controllers = controllers
    @devices = lights

    # this variable is used to
    @rh_context ||= {}
  end

  # typically used to turn something on/off. This will support the DSL syntax like:
  # turn on kitchen_light
  def switch(*args)
    # first argument should be DeviceCommand. If it's not, simply consider this word syntactic sugar.
    # (this way, both 'turn on my_light' as well as 'turn my_light on' will work)
    cmd = args[0]
    return args if !cmd.is_a?(RubyHome::Executor::DeviceCommand)
    cmd.device.send(cmd.command)
  end
  alias_method :turn, :switch


  def method_missing(method, *args)
    puts "method missing: #{method} with args: #{args.inspect}"

    # if 'on', 'off', 'dim' etc is used the intent is actual string literal, or it may be followed by a device name
    m = method.to_s
    if LITERALS.include?(m)
      if args.length == 0
        return m #return as string literal
      elsif args[0].is_a?(RubyHome::Device::BasicDevice)
        # create a DeviceCommand that will be executed by the :turn or :switch method
        return RubyHome::Executor::DeviceCommand.new(args[0], m)
      else
        raise "Don't know what to do with literal '#{m}' and arguments #{args.inspect}. '#{m}' must be followed by a device name"
      end
    end

    # check if the missing method name matches to a known device
    idx = @devices.index { |l| l.name == method }
    if idx
      device = @devices[idx]
      if (args.length >0)
        # intent was method call with arguments.
        return device.send(args.shift)
      else
        # intent was likely to just get the object
        return device
      end
    end

    raise "don't know what to do with call to: '#{method}', it doesn't appear to be a device"
  end
end
