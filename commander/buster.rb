require 'digest'
require 'fileutils'

##
# The Buster class provides cache-busting functionality.

class Buster
  attr_reader :files, :map

  ##
  # Instantiates a buster, taking an array of +files+ on which to operate on.
  # Params:
  # +files+:: an array of files
  
  def initialize(files=[])
    raise Exception.new("Expect an array, not #{ files } for Buster.new!") if (not files.is_a? Array)

    @files = files
    @map = {}
  end

  def self.[](directory=".")
    if (not directory.is_a? Array) && File.directory?(directory_or_files)
      Buster.new(Dir[File.join(directory_or_files, "**/*.*")])
    else
      raise Exception.new("Expected a directory, not #{ directory } for Buster[]!")
    end
  end
  
  ##
  # Create cache-busted versions of the files in the instance. Internally uses an
  # MD5 digest to create six values which get prepended to a file. As well,
  # the instance provides a +@map+ attribute, mapping the original filename to the
  # new busted name. 
  #
  # +bust+ will delete all previous busted files in the destination before
  # adding fresh busted files. Optionally, you can provide a +out+ destination where
  # files will be output, as well as a +preserve_tree+ option which will preserve
  # copy the origin file into the destination along with its parent folders.
  # Params:
  # +out+:: An optional destination for the newly busted files (ALL OTHER BUSTED FILES ARE REMOVED).
  # +preserve_tree+:: When copying to destination, preserve nested folders. Doesn't do anything if no +out+ is set.
  # +preserve_original+:: Whether or not to delete the original, non-hashed input files.
  # TODO: not all busted files should be deleted, only the ones belonging to this instance.

  def bust(out: nil, preserve_tree: false, preserve_original: true)
    FileUtils.mkdir_p(out) if out

    @map = @files.each_with_object({}) do |f, result|
      hash = Digest::MD5.hexdigest File.read f
      basename = File.basename f
      dirname = File.dirname f
      new_name = hash[0...6] + "_" + basename

      destination = out ? out : dirname

      if preserve_tree && destination
        dirname = out ? path_diff(dirname, out) : dirname
        destination = File.join(out, dirname)
        FileUtils.mkdir_p(destination)
      end
 
      # TODO: This will remove a hashed file if it follows the format of
      # 6letters_anything.css
      rm_busted(destination)

      FileUtils.cp f, File.join(destination, new_name)
      result[basename] = new_name
      result
    end

    FileUtils.rm(@files) if (not preserve_original)

    return self
  end

  ##
  # Will replace references to the original files in the instance with references
  # to the busted files the instance has created. This is a fairly slow operation
  # as it is implemented naively.
  # Params:
  # +files+:: An array of files in which to replace references.

  def replace_in(files=[])
    files.each do |f|
      content = File.read f
      @map.each do |original, busted|
        content = content.gsub(/#{ original }/, busted)
      end
      File.write f, content
    end
  end

  ##
  # Checks to see whether a file adheres to our busted file naming rules. These
  # are defined as 6 lower-case alphanumeric values followed by an underscore.
  # Params:
  # +filename+:: filename to check
  
  def busted?(filename)
    f = File.basename(filename)
    /\A(.*\/)?[a-z0-9]{6}_[a-zA-Z0-9\-_]+\.[a-zA-Z0-9]+\z/.match?(f)
  end

  ##
  # Removes all busted files in a given directory.
  # Params:
  # +directory+:: directory to operate on
  
  def rm_busted(directory)
    FileUtils.rm Dir[directory + "/*.*"].select { |f| busted? f }
  end

  ##
  # Utility for ensuring that nested paths, if copied, do not repeat
  # already-present parent dirs.
  # Params:
  # +path1+:: path to make unique
  # +path2+:: path to subtract
  
  def path_diff(path1, path2)
    File.join(path1.split("/") - path2.split("/"))
  end

end
