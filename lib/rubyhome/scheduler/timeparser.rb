

def parse_interval(string)
	string = string.downcase.strip

	if (cron = CronParser.parse(string))

	elsif (interval = IntervalParser.parse(string))

	end
end




@opts = {}

def weekdays 
	@opts.weekdays || [1,2,3,4,5]
end

def weekend
	@opts.weekend || [0,6]
end

day_specs = {
	:monday 	  => [1],
	:tuesday  	=> [2],
	:wednesday	=> [3],
	:thursday   => [4],
	:friday     => [5],
	:saturday   => [6],
  :sunday     => [7],
	:weekday    => weekdays,
	:weekend	  => weekend,
	:day        => weekdays + weekend
}





# 
def week_days(in)
  days = in.gsub(/ /, '').split(',')
  valid = true
  d = days.collect do |day| 
  	day_arr = DAYS[day]
  	if !day_arr
      valid = false
      break
    end
  end
  valid ? d.uniq : nil
end





'monday, wednesday, friday at 10am,4pm'
'6 hours'
'evening at 11'
'afternoon at 2'
'morning at 9'
'noon'
'midnight'
