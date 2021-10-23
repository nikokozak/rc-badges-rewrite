require 'digest'
require 'fileutils'

class Buster
  
  def initialize(files=[])
    @files = files
    @map = {}
  end
  
  def bust(destination=".")
    rm_busted(destination)

    @map = @files.each_with_object({}) do |f, result|
      hash = Digest::MD5.hexdigest File.read f
      basename = File.basename f
      new_name = hash[0...6] + "_" + basename
      
      FileUtils.cp f, File.join(destination, new_name)
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
    /\A[a-z0-9]{6}_[a-zA-Z0-9\-_]+\.[a-zA-Z0-9]+\z/.match?(f)
  end

  def rm_busted(directory)
    FileUtils.rm Dir.children(directory).select(:busted?)
  end

end
