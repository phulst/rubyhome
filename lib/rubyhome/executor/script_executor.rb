require 'rubyhome/executor/execution_context'

module RubyHome
  class ScriptExecutor

    def initialize(controllers, lights)
      @controllers = controllers
      @lights = lights
    end

    def process(file)
      # evaluate the file within the context of this object

      script_dir = File.join(File.dirname(__FILE__), "../../..", file, 'scripts')
      Dir.glob("#{script_dir}/*.rb").each do |file|
        puts "running user script: #{File.basename(file)}"

        # create a new execution context for each script.
        exec_context = ExecutionContext.new(@controllers, @lights)
        exec_context.instance_eval(File.open(file).read, file)
      end
    end

    def self.config
      @config ||= {}
      @config
    end
  end
end
