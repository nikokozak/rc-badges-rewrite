require 'pathname'

##
# Functionality for dealing with Sass (scss, sass) files.

#TODO: Restructure as instance.

class Sass
  attr_accessor :files

  def initialize(files, directory)
    @files = files
    @directory = directory
  end

  def self.[](dir=".")
    throw Exception.new("Expected a dir, got file #{ dir } in Sass[]!") if File.file? dir
    throw Exception.new("Nonexistant #{ dir } in Sass[]!") if (not File.exist? dir)
    Sass.new(Dir["**/*.{sass,scss}", base: dir], dir)
  end

  ##
  # Checks if a +file+ is a css file.
  # Params:
  # +file+:: a filename or filepath string.

  def self.is_css?(file)
    /\.css\z/.match?(file)
  end

  ##
  # Checks if a +file+ is a sass file. A sass file is defined as a file ending
  # in either sass or scss.
  # Params:
  # +file+:: a filename or filepath string.

  def self.is_sass?(file)
    /\.s(a|c)ss\z/.match?(file)
  end

  ##
  # Checks if a +file+ is a sass mixin. Mixins are defined as files that start
  # with a "_" and end in either .sass or .scss.
  # Params:
  # +file+:: a filename or filepath string.

  def self.is_mixin?(file)
    /\A(.*\/)?_.*\.s(a|c)ss\z/.match?(file)
  end

  ##
  # Call the SASS transpiler on the +input_file+. Outputs a css file if successful. Will
  # return the filepath of the transpiled css file.
  # Params:
  # +input_file+:: a filepath string, evaluated relative to the cwd.
 
  def self.call_sass(input_file, out_dir=nil)
    raise Exception.new("Could not find #{ input_file } in Sass.call_sass!") if (not File.exist?(input_file))

    basename = File.basename input_file
    dirname = File.dirname input_file

    out_dir = out_dir ? out_dir : dirname
    output_file = File.join(out_dir, basename.sub(/\.[a-zA-Z0-9]+\z/, ".css"))

    %x{sass --no-source-map #{input_file} #{output_file}}
    p "Sass compiled #{ input_file } -> #{ output_file }"

    Sass.sanitize_paths(output_file)
  end

  ##
  # Call the SASS transpiler on the instance's +@files+. Returns a list of paths
  # representing the transpiled css files.
  # Params:
  # +out+:: A directory path.

  def render(out: @directory)
    @files.each_with_object([]) do |f, result|
      local_dir = File.dirname f
      full_path = File.realpath(f, @directory)
      out_path = File.join(out, local_dir)

      if sass_and_not_mixin? full_path
        converted_file = Sass.call_sass(full_path, out_path)
        result << converted_file
      else 
        next
      end
    end
  end

  private

  def self.sanitize_paths(path)
    path.gsub(/\/\.\//, "/") 
  end

  def sass_and_not_mixin?(path)
    File.file?(path) && Sass.is_sass?(path) && (not Sass.is_mixin?(path))
  end

end
