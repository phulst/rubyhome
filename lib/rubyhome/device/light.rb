require 'rubyhome/device/basic_device'
require 'json'
require "nats/client"

# represents a light
#
module RubyHome
  module Device
    class Light < BasicDevice
      MAX_DIM = 100 # considered fully on
      MIN_DIM = 0   # considered fully off

      attr_accessor :controller_queue, :address, :name

      # initializes the light
      # provide a name, and a hash of options. Accepted options:
      # address
      # the light address (such as X10 address)
      # and optional dimmable parameter (default = true)
      def initialize(name, address, options)
        @address = address
        @name = name
        # if dimmable option not set, default to true
        @dimmable = options[:dimmable].nil? ? true : !!options[:dimmable]

        @state = :unknown
        @dim_level = 0

        @on_actions, @off_actions = [], []
        @dim_actions, @change_actions = [], []
      end

      # destroys the light.
      def destroy
      end

      # may be called by any client to turn the light on
      def on
        publish_command(:on)
        # also notify all listeners
        update_state(:on)
      end

      # may be called by any client to turn the light off
      def off
        publish_command(:off)
        # also notify all listeners
        update_state(:off)
      end

      # dim the light by a certain amount
      def dim(amount)
        if is_dimmable? # only do this if dimmable
          publish_command(:dim, :level => amount)
          # also notify all listeners
          update_state(:dim, amount)
        elsif amount == MAX_DIM
          @controller.light_on(self)
          update_state :on
        elsif amount == MIN_DIM
          @controller.light_off(self)
          update_state :off
        end
      end

      # may be used to execute a block of code when the light is turned on
      def when_on(&action)
        @on_actions << action
      end

      # may be used to execute a block of code when the light is turned off
      def when_off(&action)
        @off_actions << action
      end

      # may be used to execute a block of code when the light is dimmed
      def when_dim(&action)
        if is_dimmable?
          @dim_actions << action
        end
      end

      # may be used to execute a block of code when the light state changes
      def when_change(&action)
        @change_actions << action
      end

      def is_dimmable?
        @dimmable
      end

      # returns true if light is on (with dim level above 0)
      def is_on?
        return @state == :on
      end

      def is_off?
        return @state == :off
      end

      def state_unknown?
        return @state == :unknown
      end

      # returns true if light dim amount is greater than 0 and
      # smaller than 100
      def is_dimmed?
        return (@state == :on && @dim_amount > 0 && @dim_amount < 100)
      end

      # this method may only be used by the light controller to update state
      # of this light
      def update_state(state, dim_amount = nil)
        @state = state
        @dim_level = dim_amount if dim_amount

        # call all appropriate blocks
        if (state == :on)
          @on_actions.each {|a| a.call }
          @change_actions.each {|a| a.call(:on)}
        elsif (state == :off)
          @off_actions.each {|a| a.call }
          @change_actions.each { |a| a.call(:off)}
        elsif (state == :dim && is_dimmable?)
          @dim_actions.each {|a| a.call(dim_amount)}
          @change_actions.each {|a| a.call(:dim, dim_amount)}
        end
      end

      def publish_command(cmd, pars = {})
        cmd_str = { :cmd => cmd, :address => address }.merge(pars).to_json
        NATS.publish("#{controller_queue}.cmd.#{address}", cmd_str)
      end

      def to_s
        "{#{@name}: #{@address}, dimmable: #{@dimmable}, controller queue: #{@controller_queue}}"
      end
    end
  end
end
