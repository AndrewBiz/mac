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
    #input_parameter.each {|key, value| print "#{key} = #{value} " }
    #puts
    #option_value.each {|key, value| print "#{key} = #{value} " }
    #puts
  rescue ArgumentError => e
    puts "Could not parse YAML #{yaml_name}: #{e.message}"
    exit
  end
else
  puts "File #{yaml_name} is not a file ..."
  exit
end
#Global checks
output_path = input_parameter[:output_path]||"./temp/"
if not File.exist?(output_path)
  puts "Output dir \'#{output_path}\' does not exist!"
  exit
end
artwork = option_value[:artwork]
if not File.exists?(artwork)
  puts "Picture \'#{artwork}\' does not exist!"
  exit
end

   

# Generating bash script
fext = input_parameter[:input_file_ext]||"mov"
fmask = "*."+fext
script_name = input_parameter[:script_name]||"script_ap.sh" 
puts "MASK: #{fmask}, script: #{script_name}"

program_to_execute = input_parameter[:program_to_execute]||"action"
tvshowname = input_parameter[:tvshowname]
tvseasonnum = input_parameter[:tvseasonnum]

File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
  
  Dir.glob(fmask).each do |movie|
    current_command = program_to_execute+" \'#{movie}\'"
    #output
    current_command += " --output \'#{output_path}#{File.basename(movie)}\'"
    #processing options set by the user
    option_value.each do 
      |key, value|
      current_command += " #{option_name[key]} \'#{value}\'"
    end
    # processibg 'auto' options
    # Episode name
    movie_name = File.basename(movie, "."+fext)
    current_command += " #{option_name[:title]} \'#{movie_name}\'"
    # TV Show series name
    current_command += " #{option_name[:artist]} \'#{tvshowname}\'"
    current_command += " #{option_name[:albumartist]} \'#{tvshowname}\'"
    current_command += " #{option_name[:album]} \'#{tvshowname}, Season #{tvseasonnum}\'"
    # Episode num

    f.puts current_command
  end
end
File.chmod(0775, script_name)