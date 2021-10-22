require 'listen'
require_relative 'site.rb'

site = Site.new

listener = Listen.to(*ARGV) do |modified, added, removed|
  if modified.any? { |m| /(sass|scss|erb|svg)\z/.match(m) }
    site.render
    p "updating site...."
  end
end

listener.start
sleep
