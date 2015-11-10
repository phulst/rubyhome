
# SPECIFIC TIMES EVERY DAY
# every "16:00"
# every "8:10:00 pm"
# every 12pm, 4pm, 8pm
# every midnight

# SPECIFIC DAYS OF THE WEEK
# every monday at 4pm
# every weekend at 10:00
# every weekday at 7:00am, 5pm
# every monday, wednesday, friday at 2:00

# SPECIFIC DAYS OF THE MONTH
# every 1st of the month at noon
# every 10th of the month at 10:00, 20:00
# every 3rd,13th,23rd of the month at 3pm
class CronParser
	attr_reader :cron 




  def match_days

    "((monday|tuesday|wednesday|thursday|friday|saturday|sunday|weekday|weekend|day)\s*(,|and)?\s*)"


  end


  ((monday|tuesday|wednesday|thursday|friday|saturday|sunday|weekday|weekend|day)\s*(,|and))

	def parse(string)

	end

  # matches pattern 
  # 26th of the month at 12pm, 4pm
  def day_of_month_format(string)
  	if string =~ /(\d+)(st|nd|rd|th)?\sof the month at (.*)/
  		day = $1
  		times = parse_times($3)
  	end
  end

  # parses multiple times (using parse_time) separated by commas
  def parse_times(str)
  	str.delete(' ')
  	times = []
  	success = true
  	str.split(',').each do |t|
  	  pt = parse_time(t)
  	  if pt
  	  	times << pt
  	  else
  	  	raise "unable to parse time #{t}"
  	  	success = false
  	  	break
  	  end
  	end
  end

  # parse times like 
  #   10:30		 => { h: 10, m: 30, s: 0}
  #   16:20:55   => { h: 16, m: 20, s: 55}
  #   8:20am     => { h: 8,  m: 20, s: 0}
  #   5 PM       => { h: 17, m: 0,  s: 0}
  #   12:05am    => { h: 0,  m: 5,  s: 0}
  #   noon       => { h: 12, m: 0,  s: 0}
  #   midnight   => { h: 0,  m: 0,  s: 0}
  def parse_time(time)
  	time = time.delete(' ').downcase
  	# handle special cases 'noon' and 'midnight'
  	time = case time
  	when 'noon' then '12:00'
  	when 'midnight' then '0:00'
  	else time end

  	res = nil
  	if time =~ /^([\d]{1,2})(:([\d]{2}))?(:([\d]{2}))?(am|pm)?$/
  		hours = $1.to_i
  		minutes = ($3 || 0).to_i
  		seconds = ($5 || 0).to_i
  		ampm = $6
  		if ampm == 'pm'
  			return nil if (hours == 0 || hours > 12)
  			hours += 12 if hours < 12
  		elsif ampm == 'am'
  			return nil if hours > 12 
  			hours = 0 if hours == 12 # 12am = 0:00 
  		end
  		res = { :h => hours, :m => minutes, :s => seconds }
	end
	res
  end
end


class Cron
  
  def add_time 
  end

end

c = CronParser.new
p c.parse_time(ARGV[0])
