require 'digest'
require 'fileutils'

class Buster

  attr_reader :files, :map
  
  def initialize(files=[])
    raise Exception.new("Expect an array, not #{ files } for Buster.new!") if (not files.is_a? Array)

    @files = files
    @map = {}
  end
  
  def bust(destination=nil, preserve_tree=false)
    FileUtils.mkdir_p(destination) if destination

    @map = @files.each_with_object({}) do |f, result|
      hash = Digest::MD5.hexdigest File.read f
      basename = File.basename f
      dirname = File.dirname f
      new_name = hash[0...6] + "_" + basename

      out = destination ? destination : dirname

      if preserve_tree && destination
        dirname = destination ? path_diff(dirname, destination) : dirname
        out = File.join(destination, dirname)
        FileUtils.mkdir_p(out)
      end
      
      rm_busted(out)

      FileUtils.cp f, File.join(out, new_name)
      result[basename] = new_name
      result
    end
  end

  def replace_in(files=[])
    @map.each do |original, busted|
      files.each do |f|
        content = File.read f
        File.write f, content.gsub(/#{ original }/, busted)
      end
    end
  end

  def busted?(filename)
    f = File.basename(filename)
    /\A(.*\/)?[a-z0-9]{6}_[a-zA-Z0-9\-_]+\.[a-zA-Z0-9]+\z/.match?(f)
  end

  def rm_busted(directory)
    FileUtils.rm Dir[directory + "/*.*"].select { |f| busted? f }
  end

  def path_diff(path1, path2)
    File.join(path1.split("/") - path2.split("/"))
  end

end
