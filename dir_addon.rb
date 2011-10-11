#!/usr/bin/env ruby -w

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
# #
end
