require 'fileutils'
require 'erb'

class Renderer
  attr_accessor :queue

  ##
  # Creates a class instance with an internal queue of .erb files to process.
  # These files do not include "_*.erb" files, which are considered mixins
  # for parent files only. Can be instantiated with +[]+ as well.
  # Params:
  # +directory+:: directory to search for .erb files.

  def initialize(directory=".")
    @directory = directory
    @queue = Dir[File.join("**", '[^_]*.erb'), base: directory]
  end

  def self.[](directory=".")
    Renderer.new(directory)
  end

  ##
  # Renders html files from .erb files, rendering mixins as well. Can pass a
  # an optional +out+ directory for the files to be saved to, otherwise they are
  # rendered as siblings to their templates. When saving to a separate directory,
  # the directory structure of the templates is preserved.
  # Params:
  # +out+:: directory to save generated files to.

  def render(out: @directory, env: {})
    transformed = []

    @queue.each do |f|
      rendered = render_internal(f, env)
      basename = File.basename f, ".erb"
      dirname = File.dirname f
      outfile = File.join(out, dirname, basename + ".html")

      FileUtils.mkdir_p(File.dirname(outfile)) if (not File.exist? File.dirname(outfile))
      File.write(outfile, rendered)

      p "Transformed #{ f } -> #{ outfile }"

      transformed.push(outfile)
    end

    transformed
  end

  ##
  # Utility function that can be called from inside .erb files to render mixins.
  # You can optionally pass in an +env+ hash with variables you want accessible from
  # inside the mixin - these get added to the binding object, so the mixin can still
  # call methods from this class if necessary.
  # Params:
  # +file+:: mixin or erb file to render
  # +env+:: optional hash of variables we want accessible to the template.
  # Returns:
  # string

  def render_internal(file, env={})
    template = ERB.new(File.read File.join(@directory, file))
    b = binding
    env.each do |key, val|
      # This allows us to access values from inside nested templates
      b.local_variable_set(key.to_sym, val)
    end
    template.result b
  end

end
