require_relative '../../rubyhome/errors/errors'


module RubyHome
  class DayParser
    attr_accessor :weekdays, :weekends

    # all names and variations thereof that this class can match on.
    def names
      {
          :monday =>    'monday, mon',
          :tuesday=>    'tuesday, tue',
          :wednesday=>  'wednesday, wed',
          :thursday=>   'thursday, thu',
          :friday=>     'friday, fri',
          :saturday=>   'saturday, sat',
          :sunday=>     'sunday, sun',
          :weekend=>    'weekend',
          :weekday=>    'weekday',
          :day=>        'day',
          :and=>        'and'
      }
    end

    # this will allow you to monkey patch this class if your weekends are not saturday and sunday.
    # note that you should then also monkey patch the weekday method
    def weekend
      [6,0]
    end

    def weekday
      [1,2,3,4,5]
    end

    # parses the day names from a string and returns the day numbers (duplicates removed) as an array
    def parse_days(str)
      r = build_regex
      matches = str.scan(Regexp.new(r, Regexp::IGNORECASE))
      p matches
      if matches && matches.length > 0
        days = matches.collect do |m|
          d = find_day(m[1])
          case d
            when :weekend
              weekend
            when :weekday
              weekday
            when :day
              [0,1,2,3,4,5,6]
            else
              days_of_week.index(d)
          end
        end
        days.flatten.uniq.sort
      else
        raise RubyHome::TimeParseError, "format error in list of days: '#{str}'"
      end
    end

    private

    # builds the entire regular expression for a list of days
    def build_regex
      regex = "(("
      days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :weekday, :weekend, :day]
      days.each do |key|
        regex += build_match_pattern(names[key]) + "|"
      end
      and_ptn = build_match_pattern(names[:and])
      regex.chop + ")(\\s*(,|#{and_ptn})?\\s*)?)"
    end

    # returns the symbol for a day name
    def find_day(name)
      names.each_pair do |sym, names|
        names.split(',').each do |day|
          return sym if (name == day.strip)
        end
      end
      nil
    end

    # returns a match pattern like 'a|b|c' when passed in a string like 'a, b, c'
    def build_match_pattern(str)
      values = str.split(',')
      ptn = ""
      values.each do |s|
        ptn += "#{s.strip}|"
      end
      ptn.chop
    end

    def days_of_week
      [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    end
  end

  dp = DayParser.new
  p dp.parse_days("monday, tue, and saturday" )
end