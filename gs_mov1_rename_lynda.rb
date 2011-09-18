#!/usr/bin/env ruby -w
require "yaml"

class Dir
  def self.foreach_recursive(dir_to_process, fmask, &block)
    Dir.foreach(dir_to_process) do |item|
      if File.directory?(item)
        if (item!=".") and (item!="..")
          foreach_recursive(item, fmask, &block)
        end
      else #item=file
        matched = false
        fmask.collect{|x| matched = File.fnmatch(x, item)||matched}
        yield File.expand_path(dir_to_process), item if matched 
      end
    end
  end
end

# Parses the movie name and returnes Season, Episode, Name
#def parse_name(file_name, regexp_pattern)
#  m = Regexp.new(regexp_pattern).match(file_name)
#  if not m return nil
#  #if(m[:season]) then new_file_name += "S"+m[:season] end
#  #if(m[:episode]) then new_file_name += "E"+m[:episode] end
#  if(m[:episode1]) then new_file_name += m[:episode1] end
#  if(m[:episode2]) then new_file_name += m[:episode2] end
#  if(m[:name]) then new_file_name += " "+m[:name] end
#end

# read input args
yaml_name = ARGV[0]||"gs_mov1_rename_lynda_options.yaml"
dir_to_process = ARGV[1]||Dir.pwd
Dir.chdir(dir_to_process)

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

# Generating bash script
# get array of file exts to be processed
mov_ext = input_parameter[:mov_ext]
sbt_ext = input_parameter[:sbt_ext]
fmask = (mov_ext+sbt_ext).collect {|x| "*."+x}
# get script name
script_name = input_parameter[:script_name]||"1_ren_movie.rb" 
output_path = input_parameter[:output_path]||"." 

if not File.exists?(output_path)
  Dir.mkdir(output_path)
end

puts "MASK: #{fmask.inspect}, script: #{script_name}"
#  
program_to_execute = input_parameter[:program_to_execute]||"action"
# regexps 
mov_regexp = input_parameter[:mov_regexp]||""
srt_regexp = input_parameter[:srt_regexp]||""
#
file_prefix = output_parameter[:file_prefix]
#
subtitle_lang = output_parameter[:subtitle_lang]

# gen script
File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
  Dir.foreach_recursive(dir_to_process, fmask) do |dir, file| 
    f.puts "#***"
    full_file_name = File.join(dir, file)
    new_file_name = "#{output_path}/"
    new_file_name += file_prefix
    # get the actual extention
    if (/\.(.*)$/ =~ file) then file_ext = $1 end
    # get the actual name w/o extention
    file_name = File.basename(file, "."+file_ext)

    if sbt_ext.include?(file_ext)
      #subtitle
      #getting season episode and name
      if (srt_regexp > "") then
        m = Regexp.new(srt_regexp).match(file_name)
        if m
          #if(m[:season]) then new_file_name += "S"+m[:season] end
          #if(m[:episode]) then new_file_name += "E"+m[:episode] end
          if(m[:episode1]) then new_file_name += m[:episode1] end
          #if(m[:episode2]) then new_file_name += m[:episode2] end
          if(m[:name]) then new_file_name += " "+m[:name] end
        else
          puts "#{file}: Season or Episode or Name not found"
        end
      end
      new_file_name += "."+subtitle_lang
    else 
      #movie
      #getting season episode and name
      if (mov_regexp > "") then
        m = Regexp.new(mov_regexp).match(file_name)
        if m 
          #if(m[:season]) then new_file_name += "S"+m[:season] end
          #if(m[:episode]) then new_file_name += "E"+m[:episode] end
          if(m[:episode1]) then new_file_name += m[:episode1] end
          #if(m[:episode2]) then new_file_name += m[:episode2] end
          if(m[:name]) then new_file_name += " "+m[:name] end
        else
          puts "#{file}: Season or Episode or Name not found"
        end
      end
       
    end
    # add ext
    new_file_name += "."+file_ext 
    #write command
    current_command = program_to_execute+" \"#{full_file_name}\" \"#{new_file_name}\""
    f.puts current_command    
  end
end
#making the script executable
File.chmod(0775, script_name)