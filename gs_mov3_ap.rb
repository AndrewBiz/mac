#!/usr/bin/ruby
require "yaml"

# read input args
yaml_name = ARGV[0]||"gs_mov3_ap_options.yaml"

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
output_path = input_parameter[:output_path]||"/Volumes/WD/mov/3_tagged/"+"mov_"+rand(1000).to_s
if not File.exist?(output_path)
  Dir.mkdir(output_path)
end

artwork = option_value[:artwork]
if not File.exists?(artwork)
  puts "Picture \'#{artwork}\' does not exist!"
  exit
end
#track_number_pos = input_parameter[:track_number_pos].to_i
#track_number_len = input_parameter[:track_number_len].to_i
   

# Generating bash script
fext = input_parameter[:input_file_ext]||"mov"
fmask = "*."+fext
script_name = input_parameter[:script_name]||"script_ap.rb" 
puts "MASK: #{fmask}, script: #{script_name}"

program_to_execute = input_parameter[:program_to_execute]||"action"
tvshowname = option_value[:tvshowname]

# not used any more tvseasonnum = option_value[:tvseasonnum]

File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
  
  Dir.glob(fmask).each do |movie|
    f.puts "#***"
    #1st remove old metadata
    f.puts "#*** Remove old metadata and pictures ***"
    f.puts "echo \"*** PROCESSING  #{movie} - cleaning old tags\""
    f.puts program_to_execute+" \"#{movie}\""+" --output \"#{output_path}/#{File.basename(movie)}\""+" --artwork REMOVE_ALL --metaEnema"
    #2nd update metadata
    f.puts "#*** Update metadata and pictures ***"
    f.puts "echo \"*** PROCESSING  #{movie} - adding new tags\""
    current_command = program_to_execute+" \"#{output_path}/#{File.basename(movie)}\" --overWrite"
    #processing options set by the user
    option_value.each do 
      |key, value|
      current_command += " #{option_name[key]} \"#{value}\""
    end
    # processibg 'auto' options
    # Episode name
    movie_name = File.basename(movie, "."+fext)
    current_command += " #{option_name[:title]} \"#{movie_name}\""
    # Get season from filename. Expecting Snn format
    if (/S(\d\d)/ =~ movie_name) then 
      tvseasonnum = $1
    else   
      tvseasonnum = 1
    end
    current_command += " #{option_name[:tvseasonnum]} \"#{tvseasonnum}\""
    # TV Show series name
    current_command += " #{option_name[:artist]} \"#{tvshowname}\""
    current_command += " #{option_name[:albumartist]} \"#{tvshowname}\""
    current_command += " #{option_name[:album]} \"#{tvshowname}, Season #{tvseasonnum}\""
    #tvepisodenum = movie_name[track_number_pos, track_number_len]
    # Get Episode num from filename. Expecting En(nnn) format 
    if (/E(\d{1,4})\s*/ =~ movie_name)||(/(\d{4})\s*/ =~ movie_name) then 
      tvepisodenum = $1
    else   
      tvepisodenum = 1
    end
    current_command += " #{option_name[:tvepisodenum]} \"#{tvepisodenum}\""
    current_command += " #{option_name[:tracknum]} \"#{tvepisodenum}\""
    episode_id = "S"+tvseasonnum.to_s.rjust(2,"0")+"E"+tvepisodenum   #SssEee format
    current_command += " #{option_name[:tvepisode]} \"#{episode_id}\""
    
    f.puts current_command
  end
end
File.chmod(0775, script_name)