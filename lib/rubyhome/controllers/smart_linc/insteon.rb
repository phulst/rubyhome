module SmartLinc
  module Insteon
    # insteon device commands
    INSTEON_COMMANDS = {
      :on       => 11,
      :fast_on  => 12,
      :off      => 13,
      :fast_off => 14
    }

    # insteon dim levels
    INSTEON_LEVELS = [{ 0 => '00'}, {10 => '19'}, {25 => '40'}, {50 => '7F'}, {75 => 'BF'}, {90 => 'E6'}, {100 => 'FF'}]

    def parse_insteon_address(address)
      addr = address.delete('.').upcase
      raise "#{address} is not a valid Insteon address" if addr !~ /[0-9A-F]{6}/
      addr
    end

    def insteon_command_string(insteon_address, command, level = 100)
      raise "level must be between 0 and 100" if level < 0 || level > 100
      # todo: check for valid Insteon address

      begin_insteon = "0262"
      address = parse_insteon_address(insteon_address)

      standard_cmd = '0F'
      cmd = INSTEON_COMMANDS[command]

      # determine level code (this works even if levels don't match exactly with INSTEON_LEVELS,
      # ie for level 20 it will return the level code for 25%, and for level 92 it will return code for 100%
      level_code = 0
      INSTEON_LEVELS.each do |l|
        v = l.keys[0]
        if level <= v
          level_code = l[v]
          break
        end
      end

      "#{begin_insteon}#{address}#{standard_cmd}#{cmd}#{level_code}"
    end

  end
end
