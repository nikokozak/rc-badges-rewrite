require 'pathname'

##
# Functionality for dealing with Sass (scss, sass) files.

#TODO: Restructure as instance.

class Sass

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
  # Call the SASS transpiler on the +input_file+. Outputs a css file if successful.
  # Params:
  # +input_file+:: a filepath string, evaluated relative to the cwd.
 
  def self.call_sass(input_file, out_dir=".")
    raise Exception.new("Could not find #{ input_file } in Sass.call_sass!") if (not File.exist?(input_file))

    output_file = input_file.sub(/\.[a-zA-Z0-9]+\z/, ".css")
    %x{sass #{input_file} #{output_file}}

    p "Sass compiled #{ input_file } -> #{ output_file }"
  end

  ##
  # Call the SASS transpiler on a given +directory+. Will search all subdirs
  # recursively, evaluating sass files, skipping mixins and others.
  # Params:
  # +directory+:: A directory path.

  def self.render(out: '.')
    raise Exception.new("No such directory #{ out } in Sass.run!") if (not File.directory? out)
    raise Exception.new("Expected a directory, not file #{ out } in Sass.run!") if (File.file? out)

    Dir['**/*', base: out].each do |f|
      f = File.realpath(f, out)

      File.file?(f) && is_sass?(f) && (not is_mixin? f) ? call_sass(f) : next
    end
  end

end
