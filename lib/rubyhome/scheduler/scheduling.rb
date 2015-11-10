#require 'rubygems'
require 'eventmachine'
require 'rufus/scheduler'
require 'chronic_duration'
require 'chronic'

module RubyHome
  module Scheduling

    def self.included(base)
      puts "scheduler included"

      ChronicDuration.raise_exceptions = true
    end

    def self.start_scheduler
      RubyHome::ScriptExecutor.config[:scheduler]

      Thread.new { EventMachine.run }
      sleep 2

      @rh_context ||= {}
      EM.run do
        puts "starting scheduler..."

        RubyHome::ScriptExecutor.config[:scheduler] = Rufus::Scheduler::EmScheduler.start_new
        puts "scheduler started"
      end
    end

    def every(t, s=nil, opts={}, &block)
      # parse duration to seconds
      secs = parse_every_spec(t, s, opts)
      # TODO:check if integer and call either scheduler.every or scheduler.cron
      if secs.is_a?(Integer) && secs > 0
        puts "doing something every #{secs} seconds"
        scheduler.every("#{secs}s",s,opts, &block)
      elsif secs.is_a?(String)
        puts "got 'every' cron job!"
      end
    end

    def at(t, s=nil, opts={}, &block)
      time = Chronic.parse(t)
      puts "doing something at #{time}"
      scheduler.at(time, s, opts, &block)
    end

    private

    def scheduler
      RubyHome::ScriptExecutor.config[:scheduler]
    end

    def parse_at_spec(t, s, opts)

    end

    # splits a time spec on 'at'. Returns an array of days
    def split_on_at(str)
      s = str.split(/\Wat\W/)
      if s.length == 2
        [parse_days(s[0]), parse_times(s[1])]
      else
        # TODO: no 'blah at blah' format
      end
    end

    # splits a string on a number of preset delimiters, and returns extracted values.
    # ie. 'monday, tuesday and wednesday' returns ['monday', 'tuesday', 'wednesday']
    def list_split(str, delimiters = [',', 'and'])
      ptn = "(\W#{delimiters.join('\W|\W')}\W)"
      values = []
      str.split(Regexp.new(ptn)).each do |val|
        v = val.strip
        values << v if (v.length > 0 && !delimiters.include?(v))
      end
      values
    end

    def parse_times(str)

    end

    def parse_days(str)

    end




    # parses 'every' spec and returns either a number (for second interval)
    # or a string for a cron spec
    def parse_every_spec(t, s, opts)
      secs = 0


      begin
        # first, try simple duration, like every '10 minutes'
        return ChronicDuration.parse(t)
      rescue ChronicDuration::DurationParseError
        # try something else
        raise TimeParseError, "can't parse: '#{t}'"
      end

      secs
    end
  end

end


#