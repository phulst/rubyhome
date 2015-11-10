
class Runner

  def process_files
    base_dir = "../myhome"
    Dir.glob("#{base_dir}/*.rb").each do |file|
      load file
      #each_event do |name, event|
      #  env = Object.new each_setup do |setup|
      #  env.instance_eval &setup
      #end
      #puts "ALERT: #{name}" if env.instance_eval &event end
    end
  end
end
