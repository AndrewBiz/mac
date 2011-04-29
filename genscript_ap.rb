#!/usr/bin/ruby
require "yaml"

# read input args
yaml_name = ARGV[0]||"genscript_options.yaml"

# read script_options
if File.file?(yaml_name)
  begin
    parsed_options = YAML.load_file(yaml_name)
    input_parameter = parsed_options[:input_parameter]
    option_name = parsed_options[:option_name]
    option_value = parsed_options[:option_value]
    input_parameter.each {|key, value| print "#{key} = #{value} " }
    puts
    option_value.each {|key, value| print "#{key} = #{value} " }
    puts
  rescue ArgumentError => e
    puts "Could not parse YAML #{yaml_name}: #{e.message}"
    exit
  end
else
  puts "File #{yaml_name} is not a file ..."
  exit
end

# Generating bash script
fmask = input_parameter[:input_file_mask]||"*.mov"
script_name = input_parameter[:script_name]||"script_ap.sh" 
puts "MASK: #{fmask}, script: #{script_name}"

program_to_execute = input_parameter[:program_to_execute]||"action"

File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
  
  Dir.glob(fmask).each do |movie|
    f.puts program_to_execute+" \"#{movie}\" -t"
  end
end
File.chmod(0775, script_name)