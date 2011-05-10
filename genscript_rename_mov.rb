#!/usr/bin/ruby
require "yaml"

# read input args
yaml_name = ARGV[0]||"genscript_rename_mov_options.yaml"

# read script_options
if File.file?(yaml_name)
  begin
    parsed_options = YAML.load_file(yaml_name)
    input_parameter = parsed_options[:input_parameter]
    #p(input_parameter)
    output_parameter = parsed_options[:output_parameter]
    #p(output_parameter)
  rescue ArgumentError => e
    puts "Could not parse YAML #{yaml_name}: #{e.message}"
    exit
  end
else
  puts "File #{yaml_name} is not a file ..."
  exit
end

#Global checks
=begin
output_path = input_parameter[:output_path]||"./temp/"
if not File.exist?(output_path)
  puts "Output dir \'#{output_path}\' does not exist!"
  exit
end
=end

# Generating bash script
# get array of file exts to be processed
mov_ext = input_parameter[:mov_ext]
sbt_ext = input_parameter[:sbt_ext]
fmask = (mov_ext+sbt_ext).collect {|x| "*."+x}
# get script name
script_name = input_parameter[:script_name]||"script_rename.rb" 
puts "MASK: #{fmask.inspect}, script: #{script_name}"
#  
program_to_execute = input_parameter[:program_to_execute]||"action"
# regexps 
s_regexp = input_parameter[:s_regexp]||""
e_regexp = input_parameter[:e_regexp]||""
n_regexp = input_parameter[:n_regexp]||""
#
file_prefix = output_parameter[:file_prefix]
#
subtitle_lang = output_parameter[:subtitle_lang]

# gen script
File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
  Dir.glob(fmask).each do |file|
    f.puts "#***"
    new_file_name = ""
    new_file_name += file_prefix
    # get the actual extention
    if (/\.(.*)$/ =~ file) then file_ext = $1 end
    # get the actual name w/o extention
    file_name = File.basename(file, "."+file_ext)
    #getting season
    if (s_regexp > "") then
      m = Regexp.new(s_regexp).match(file_name)
      if m 
        new_file_name += "S"+m[1] 
      else
        puts "#{file}: Season not found"
      end
    end
    #getting episode
    if (e_regexp > "") then
      m = Regexp.new(e_regexp).match(file_name)
      if m 
        new_file_name += "E"+m[1] 
      else
        puts "#{file}: Episode not found"
      end
    end
    #getting episode name
    if (n_regexp > "") then
      m = Regexp.new(n_regexp).match(file_name)
      if m 
        new_file_name += " "+m[1] 
      else
        puts "#{file}: Episode Name not found"
      end
    end
    #for subtitle - adding lang
    if sbt_ext.include?(file_ext)
      new_file_name += "."+subtitle_lang 
    end
    # add ext
    new_file_name += "."+file_ext 
    #write command
    current_command = program_to_execute+" \"#{file}\" \"#{new_file_name}\""
    f.puts current_command
  end
end
#making the script executable
File.chmod(0775, script_name)