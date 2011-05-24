#!/usr/bin/ruby
require "yaml"

#version 1
def each_file_from_here(dir_to_process, fmask, &block)
  return until File.directory?(dir_to_process)
  # 1st process all files
  Dir.chdir(dir_to_process) do
    dir = Dir.pwd
    Dir.glob(fmask).each do |file|
      yield dir, file 
    end
  end
  # 2st process all subdirs
  Dir.foreach(dir_to_process) do |dir|
    if ((dir!=".") and (dir!="..") and (File.directory?(dir)))
      each_file_from_here(dir, fmask, &block) 
    end
  end
end

#version 2
def foreach_recursive(dir_to_process, fmask, &block)
  Dir.foreach(dir_to_process) do |item|
    if File.directory?(item)
      if (item!=".") and (item!="..")
        #Dir.chdir(item) {foreach_recursive(item, fmask, &block)}
        foreach_recursive(item, fmask, &block)
      end
    else #item=file
      matched = false
      fmask.collect{|x| matched = File.fnmatch(x, item)||matched}
      yield File.expand_path(dir_to_process), item if matched 
    end
  end
end

#Procedure
def process_dir(dir_to_process, fmask)
  return until File.directory?(dir_to_process)
  # 1st process all files
  puts "*** dir_to_process=#{dir_to_process} ***"
  Dir.chdir(dir_to_process) do
    dir = Dir.pwd
    Dir.glob(fmask).each do |file|
      puts dir
      puts file
    end
  end
  # 2st process all subdirs
  Dir.foreach(dir_to_process) do |dir|
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

puts "!!! CLASSIC !!!"
process_dir(Dir.pwd, fmask)

puts
puts "!!! VIA BLOCK !!!"
each_file_from_here(Dir.pwd, fmask) {|dir, file| 
  puts dir 
  puts file
}
puts
puts "!!! VIA BLOCK 2!!!"
foreach_recursive(Dir.pwd, fmask) {|dir, file| 
  puts dir 
  puts file
}

