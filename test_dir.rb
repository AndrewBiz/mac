#!/usr/bin/ruby
require "yaml"

#Procedure
def process_dir(dir_to_process, fmask)
  return until File.directory?(dir_to_process)
  # 1st process all files
  puts "*** dir_to_process=#{dir_to_process} ***"
  Dir.chdir(dir_to_process) do
    puts Dir.pwd
    Dir.glob(fmask).each do |file|
      puts file
    end
  end
  # 2st process all subdirs
  Dir.foreach(dir_to_process).each do |dir|
    if ((dir!=".") and (dir!="..") and (File.directory?(dir)))
      process_dir(dir, fmask) 
    end
  end
end

# read input args
yaml_name = ARGV[0]||"test_dir_options.yaml"

# read script_options
if File.file?(yaml_name)
  begin
    parsed_options = YAML.load_file(yaml_name)
    input_parameter = parsed_options[:input_parameter]
    output_parameter = parsed_options[:output_parameter]
  rescue ArgumentError => e
    puts "Could not parse YAML #{yaml_name}: #{e.message}"
    exit
  end
else
  puts "#{yaml_name} is not a file ..."
  exit
end

#Global checks
# Generating bash script
# get array of file exts to be processed
mov_ext = input_parameter[:mov_ext]
sbt_ext = input_parameter[:sbt_ext]
fmask = (mov_ext+sbt_ext).collect {|x| "*."+x}

process_dir(Dir.pwd, fmask)

