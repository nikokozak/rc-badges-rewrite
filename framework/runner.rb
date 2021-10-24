require 'listen'
require_relative 'site.rb'

site = Site.new

listener = Listen.to(*ARGV, only: /(sass|scss|erb|svg)\z/) do |modified, added, removed|
  site.render
  p "updating site...."
end

listener.start
sleep
