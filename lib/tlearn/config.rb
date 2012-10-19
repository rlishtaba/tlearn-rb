module TLearn
  class Config
    WORKING_DIR = File.dirname(__FILE__) + '/../../data'
    TLEARN_NAMESPACE = 'evaluator'
    NUMBER_OF_RESET_TIMEPOINTS = 3497
    DEFAULT_NUMBER_OF_SWEEPS = 1333000
    
    def initialize(config)
      @connections_config = config[:connections] || {}
      @special_config     = config[:special]     || {}
      @nodes_config       = config[:nodes]       || {}
    end

    def setup_config(training_data)
      File.open("#{file_root}.cf",    "w") {|f| f.write(evaulator_config(training_data))}
    end

    def setup_fitness_data(data)
      File.open("#{file_root}.data",  "w") {|f| f.write(build_data(data))}
    end

    def setup_training_data(training_data)
      File.open("#{file_root}.reset", "w") {|f| f.write(build_reset_config(training_data))}
      File.open("#{file_root}.data",  "w") {|f| f.write(build_data(training_data))}
      File.open("#{file_root}.teach", "w") {|f| f.write(build_teach_data(training_data))}
    end
    
    def number_of_sweeps
      DEFAULT_NUMBER_OF_SWEEPS
    end

    private   
    def file_root
      "#{WORKING_DIR}/#{TLEARN_NAMESPACE}"
    end

    def evaulator_config(training_data)
      nodes_config = {
        :nodes => @nodes_config[:nodes],
        :inputs => training_data.no_of_inputs,
        :outputs => training_data.no_of_outputs,
        :output_nodes => '41-46'
      }
  
      output_nodes = nodes_config.delete(:output_nodes)
      node_config_strings = nodes_config.map{|key,value| "#{key.to_s.gsub('_',' ')} = #{value}" }
      node_config_strings << "output nodes are #{output_nodes}"

      connection_config_strings = @connections_config.map{|mapping| "#{mapping.keys[0]} from #{mapping.values[0]}" }
      connection_config_strings =  ["groups = #{0}"] + connection_config_strings
    

      config = <<EOS
NODES:
#{node_config_strings.join("\n")}
CONNECTIONS:
#{connection_config_strings.join("\n")}
SPECIAL:
#{@special_config.map{|key,value| "#{key} = #{value}" }.join("\n")}
EOS
    end

    def build_data(training_data)
      data_file = <<EOS
distributed
#{training_data.no_of_data_values}
#{training_data.data.map{|d| d.join(" ")}.join("\n")}
EOS
    end

    def build_teach_data(training_data)
      data_strings = training_data.output_data.map{|d| d.join(" ")}
      data_strings = data_strings.each_with_index.map{|data, index| "#{index} #{data}" }
      
      teach_file = <<EOS
distributed
#{training_data.no_of_data_values}
#{data_strings.join("\n")}
EOS
    end
  
    def build_reset_config(training_data)
      reset_points = training_data.reset_points
      reset_file = <<EOS
#{reset_points.join("\n")}
EOS
    end
    
    def number_of_outputs(training_data)
      training_data.values[0].length
    end
    
  end
end