require 'optparse'

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: svg_concat.rb -w FOLDER"

  opts.on("-w", "--watch FOLDER", "Watch the FOLDER for changes.") do |folder|
    puts "You chose to watch #{ folder }!"
    options[:folder] = folder
  end
end

option_parser.parse!

if options[:folder].nil?
  puts option_parser.help
  exit 1
end
