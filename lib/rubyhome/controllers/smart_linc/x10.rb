module SmartLinc
  module X10

  	# character codes used for commands, house codes and unit codes
  	CHAR_CODES = %w(6 E 2 A 1 9 5 D 7 F 3 B 0 8 4 C)

	  # X10 commands. these map to char_codes above, so do not change order or add items!
  	X10_COMMANDS = [
  	  :all_lights_off, 
  	  :status_off, 
  	  :on, 
  	  :preset_dim, 
  		:all_lights_on, 
  		:hail_ack, 
  		:brighten, 
  		:status_on,
  		:extended_code, 
  		:status_req, 
  		:off, 
  		:preset_dim2, 
  		:all_off, 
  		:hail_req, 
  		:dim, 
  		:extended_data
  	]

    # returns the x10 device code as needs to be transmitted to the SmartLinc
    # @param x10_address external X10 address with house- and unit code, ie. 'A6'    
    def device_code(x10_address)
      if x10_address && x10_address.length >= 2
        house_code = x10_address.upcase[0]
        unit_code  = x10_address[1..-1].to_i

        if house_code =~ /[A-P]/ && unit_code.between?(1,16)
           return "#{CHAR_CODES[house_code.ord-65]}#{CHAR_CODES[unit_code-1]}"
        end
      end
      fail "Invalid X10 address: #{x10_address}"
    end 

    # creates a pause code
    # @param length the length of the pause (integer 0 or higher)
    def pause(length)
      "P#{length}"
    end

    # assembles the entire X10 SmartLinc command string
    # @param x10_address the address, ie. 'F12'
    # @param command from X10_COMMANDS
    def x10_command_string(x10_address, command)
      cmd_index = X10_COMMANDS.index(command)
        fail "Invalid X10 command" if !cmd_index

      begin_x10 = "0263"
      finish_address = "00"
      finish_command = "80"

      dev_code  = device_code(x10_address)
      x10_command = "#{dev_code[0]}#{CHAR_CODES[cmd_index]}"
      "#{begin_x10}#{dev_code}#{finish_address}#{pause(0)}#{begin_x10}#{x10_command}#{finish_command}"
    end 

  end
end