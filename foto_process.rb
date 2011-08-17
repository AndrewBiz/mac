#!/usr/bin/env ruby -w
require "yaml"

def read_input_params
    # read input args
    dir_to_process = ARGV[0]||Dir.pwd
    if File.exist?(dir_to_process) and File.directory?(dir_to_process)
      Dir.chdir(dir_to_process)
    else
      puts "DIR #{dir_to_process} does not exist"
      exit
    end

    yaml_name = ARGV[1]||File.join(dir_to_process, File.basename(__FILE__, ".rb")+"_options.yaml")
    # read script_options
    if File.file?(yaml_name)
      begin
        options = YAML.load_file(yaml_name)
      rescue ArgumentError => e
        puts "Could not parse YAML #{yaml_name}: #{e.message}"
        exit
      end
    else
      puts "File #{yaml_name} does not exist ..."
      exit
    end
    return [dir_to_process, options]
end

# init
dir_to_process, options = read_input_params

foto_ext = options[:input_parameter][:foto_ext]
fmask_foto = foto_ext.collect {|x| File.join("**", "*."+x)}
video_ext = options[:input_parameter][:video_ext]
fmask_video = video_ext.collect {|x| File.join("**", "*."+x)}

foto_author_aka = options[:output_parameter][:foto_author_aka]||"ANB"
foto_author = options[:output_parameter][:foto_author]||"Andrey Bizyaev, aka ANB (c)"

output_path = options[:input_parameter][:output_path]||"." 
Dir.mkdir(output_path) unless File.exists?(output_path)
puts
puts "Initial run FOTO"
puts "DIR: #{dir_to_process} MASK: #{fmask_foto.inspect}"
count_foto = 0
Dir.glob(fmask_foto) do |file|
  print "*"
  count_foto += 1
#    f.puts "echo \"*** #{count} **\""
  full_file_name = File.realpath(file)
  file_ext = File.extname(file)
  file_name = File.basename(file, file_ext)
puts full_file_name 
  #change flags
#    f.puts "chflags nouchg #{full_file_name}"
#    f.puts "chmod go=u-w #{full_file_name}" 
  
  if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
    origin_file_name = $2
    #move - do not change name origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"   
    #puts new_file_name
  
  elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
    origin_file_name = $2
    #rename to origin
    new_file_name = File.join(output_path, origin_file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  else
    # for all others names rename to origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  end
end #glob 
puts "TOTAL FOTO files proceed: #{count_foto}"

puts
puts "Initial run VIDEO"
puts "DIR: #{dir_to_process} MASK: #{fmask_video.inspect}"
count_video = 0
Dir.glob(fmask_video) do |file|
  print "*"
  count_video += 1
#    f.puts "echo \"*** #{count} **\""
  full_file_name = File.realpath(file)
  file_ext = File.extname(file)
  file_name = File.basename(file, file_ext)
puts full_file_name 
  #change flags
#    f.puts "chflags nouchg #{full_file_name}"
#    f.puts "chmod go=u-w #{full_file_name}" 
  
  if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
    origin_file_name = $2
    #move - do not change name origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"   
    #puts new_file_name
  
  elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
    origin_file_name = $2
    #rename to origin
    new_file_name = File.join(output_path, origin_file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  else
    # for all others names rename to origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  end
end #glob
puts "TOTAL VIDEO files proceed: #{count_video}"

#making the script executable
#File.chmod(0775, script_name)

# http://miniexiftool.rubyforge.org/
# gem install mini_exiftool