#!/usr/bin/env ruby -w
require "rubygems"
require "yaml"
require "date"
require "logger"
require "mini_exiftool" # gem install mini_exiftool (http://miniexiftool.rubyforge.org/)
require "progressbar" #gem install progressbar (https://github.com/jfelchner/ruby-progressbar)

# *** GLOBAL Constants and Variables ***
$DateTimeFormat = '%F %T %z'

# *** Standard Ruby class - anb alter ***
class Exception
  def full_message(info=nil)
    msg = "#{self.class}: #{info} #{message}"
    msg += ". Backtrace: #{backtrace.inspect}" if $log.debug?
    return  msg
  end
end

# *** Standard Ruby class - anb alter ***
class Logger
  attr_reader :logdev
end

# *** Exception class ***
class MyFatalError < StandardError; end

# *** Read input params
def read_input_params
  #utility sub
  def find_first_yaml_file(dir_to_process)
    Dir.chdir(dir_to_process)
    yaml_file = nil
    Dir.glob("*.yaml") do |file|
      yaml_file = file
      break
    end  
    return yaml_file  
  end

  # read input args
  dir_to_process = ARGV[0]||Dir.pwd
  if not File.exist?(dir_to_process) 
    fail("#{dir_to_process} does not exist") #or raise
  end
  if not File.directory?(dir_to_process)
    fail("#{dir_to_process} is not a Directory")
  end

  yaml_name = ARGV[1]||find_first_yaml_file(dir_to_process)
  # read script_options
  if File.file?(yaml_name)
    begin
      options = YAML.load_file(yaml_name)
    rescue ArgumentError => e
      fail(e.full_message("- Parsing YAML #{yaml_name} - "))
    end
  else
    fail("YAML File #{yaml_name} does not exist ...")
  end
  return [dir_to_process, options]
end

# *** Foto object ***
class FotoObject

  # Class attributes and methods
  @@collection = []
  @@errors_occured = false

  def self.collection
    @@collection
  end
  def self.errors_occured
    @@errors_occured
  end
  
  def self.init_collection dir_to_process=Dir.pwd, ext_to_process=["jpg"]
    @@collection.clear
    @@errors_occured = false
    Dir.chdir(dir_to_process)
    fmask = "*.{#{ext_to_process * ","}}"
    $log.info "Initial scan DIR: #{dir_to_process}, MASK: #{fmask}"
    # fake loop - to count files
    files2process = 0
    Dir.glob(fmask, File::FNM_CASEFOLD) do |file|
      files2process += 1
    end #glob
    # real loop
    pbar = ProgressBar.new("Initial scan", files2process)
    Dir.glob(fmask, File::FNM_CASEFOLD) do |file|
      $log.info "Processing #{file}"
      photo = self.new(file)
      pbar.inc
    end #glob
    pbar.finish
    $log.info "TOTAL files scanned: #{self.collection.count}"
  end
  
  # Instance attributes and methods
  attr_reader :filename_original
  attr_accessor :name, :extention, :directory, :date_time_original, :file_modify_date, :errors
  
  def initialize filename=nil
    @errors = []
    @extention = File.extname filename
    @name = File.basename filename, extention
    @directory = File.expand_path(File.dirname(filename))
    @filename_original = File.realpath filename
    
    # read exif info
    @date_time_original = DateTime.civil #zero date
    @file_modify_date = DateTime.civil
    begin 
      exif = MiniExiftool.new filename, :convert_encoding => true, :timestamps => DateTime
      @date_time_original = exif.date_time_original
      @file_modify_date = exif.file_modify_date
    rescue MiniExiftool::Error => e
      $log.error e.full_message(@name)
      @@errors_occured = true 
      @errors << e.full_message
    rescue Exception => e
      $log.error e.full_message(@name)
      @@errors_occured = true 
      @errors << e.full_message
    end

    @@collection << self
  end
end

# ********** MAIN PROGRAM **********
# initializing
begin #*** GLOBAL BLOCK
  $log = Logger.new(File.basename((__FILE__), File.extname(__FILE__))+".log", 'daily')
  $log.level = Logger::DEBUG #DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  $log.info "*** STARTING command #{__FILE__} #{ARGV.inspect}"
  $log.info "Current dir is #{Dir.pwd}"

  dir_to_process, options = read_input_params

  # Event dates
  begin
    $event_date_start = DateTime.strptime(options[:event][:date_start], $DateTimeFormat)
  rescue => raised_msg
    msg = "Initializing $event_date_start: #{raised_msg}"; puts msg; $log.fatal msg
    exit false
  end

  begin
    $event_date_end = DateTime.strptime(options[:event][:date_end], $DateTimeFormat)
  rescue => raised_msg
    msg = "Initializing $event_date_end: #{raised_msg}"; puts msg; $log.fatal msg
    exit false
  end
    

  begin
    raise MyFatalError, '$event_date_end less than $event_date_begin' unless  $event_date_end >= $event_date_start 

  rescue MyFatalError => e
    puts e.full_message; 
    $log.fatal e.full_message 
    exit false

  rescue RuntimeError => e  # or use $! instead
    puts e.full_message; 
    $log.fatal e.full_message 
    fail
  else
    # All ok = No exceptions
    msg = "Event dates: #{$event_date_start.to_date}..#{$event_date_end.to_date}"; puts msg; $log.info msg
  end

  FotoObject.init_collection(dir_to_process, options[:input_parameter][:foto_ext])

    FotoObject.collection.each do |foto|
puts
      p foto
puts
      #print foto.name; puts foto.extention
      #puts "DTO = #{foto.date_time_original}"
      #puts "FMD = #{foto.file_modify_date}"

    end

rescue RuntimeError => e  # or use $! instead
  $log.fatal e.full_message 
  puts "Exit on FATAL errors. See #{$log.logdev.filename} for details"
  exit false

rescue Exception => e
  $log.fatal e.full_message 
  puts "Exit on FATAL errors. See #{$log.logdev.filename} for details"
  exit false

else
  # No Exceptions = All is Ok

ensure
  # Do it anyway
  $log.info "*** ENDING command #{__FILE__}"
  $log.close
end # *** GLOBAL BLOCK