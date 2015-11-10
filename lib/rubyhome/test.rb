require './smart_linc/controller.rb'

controller = SmartLinc::Controller.new("192.168.0.16")
controller.send_x10_command('G4', :off)

sleep(5)

controller.send_x10_command('G4', :on)


every 'monday, wednesday, friday at 8am' do

  irrigate('5 minutes') do
    lawn
    back '3 minutes'
    front '1 minute'
    deck  '5 minutes'
  end

end



lights {
  kitchen_light {controller: 'smartlinc'}
}


kitchen_light on_for '5 minutes'



kitchen_light :on, '5 minutes' :off

for_duration '5 minutes' do
  kitchen_light :on
  hallway_light :on

end

default_device_controller 'smart_linc'

devices {
  kitchen_light 'P12'
  recess_light  'G3'
}

default_sensor_controller 'W32800RF'
sensors {
  kitchen_motion ''
}

kitchen_light.link_sensor(kitchen_motion, '5 minutes')

kitchen_motion.on_activation {
  kitchen_light.turn_on_for '5 minutes'
}


spaces {
  living_room {
    kitchen_light
  }
  kitchen {
    kitchen_light
  }
}