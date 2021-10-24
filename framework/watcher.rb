require 'listen'
require_relative 'site.rb'

class Watcher
  def initialize(site, watch_folders, only: /(sass|scss|erb|svg)\z/)
    @site = site
    @watch = watch_folders
    @only = only

    @listener = Listen.to(*@watch, only: @only) do |modified, added, removed|
      @site.build
      p "rebuilding site..."
    end
  end

  def run
    @listener.start
    sleep
  end
end
