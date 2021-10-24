require_relative 'sass.rb'
require_relative 'renderer.rb'

##
# Handles the creation of "tag trees", i.e. hashes with nodes describing
# our svg tags and their styles.

class Tags

  ##
  # Creates a Tag class initialized to a base +directory+, where "tags" (i.e. folders
  # representing categories, within which pairings of svg files and sass or css files
  # of the same name) should be found.
  # Params:
  # +directory+:: A directory string

  def initialize(directory="tags")
    @directory = directory
  end

  def self.[](directory="tags")
    Tags.new(directory)
  end

  ##
  # Creates a tree-like structure of nodes carrying tag information.
  # Looks for an svg file, from which it derives its matching css file.
  # The parent folder for any given svg file is used as its category,
  # which becomes the key in the map holding it and its sibling tags.

  def tree
    Dir.chdir(@directory) do
      Dir['**/*'].reduce({}) do |result, f|
        if File.file?(f) && is_svg?(f)
          node = build_node(f)
          cat = node[:category]
          # TODO: Clean this up
          node[:copyable] = Renderer.new('../templates').render_internal('_tag.erb', {tag: node})
          result[cat] = (result[cat] || []).push(node)
          result
        else
          result
        end
      end
    end
  end

  private

  ##
  # Builds a node for the tag tree using a +file+ (svg) as reference.
  # In order to build successfully, there must be an associated css
  # file with the same basename as the svg file passed into the function.
  # Params:
  # +file+:: Filename as string (svg file)

  def build_node(file)
    parent = parent_folder(file)
    category = parent == "." ? to_symbol(@directory) : to_symbol(parent)
    basename = basename(file)
    title = basename_to_title(basename)
    css_path = ensure_exists(change_extension(file, ".css"))
    style = File.read(css_path)
    svg_path = file
    svg_contents = File.read(svg_path)

    { title: title,
      basename: basename,
      style: style,
      svg_path: svg_path,
      svg_contents: svg_contents,
      path: File.realpath(file),
      category: category }
  end

  ##
  # Extracts the basename from a filename.
  # Params:
  # +file+:: filename string

  def basename(file)
    File.basename(file, ".*")
  end

  ##
  # Returns the parent folder for the file. Uses Pathname internally.
  # Params:
  # +file+:: a filename string

  def parent_folder(file)
    Pathname.new(file).dirname.basename.to_s
  end

  ##
  # Removes dashes and underscores from a +basename+, replacing them with
  # spaces.
  # Params:
  # +basename+:: a basename string

  def basename_to_title(basename)
    basename.gsub(/[\-_]/, " ").capitalize
  end

  ##
  # Santitizes a +string+ by removing dashes and underscores, converting it
  # into a symbol.
  # Params:
  # +string+:: a string

  def to_symbol(string)
    string.gsub(/[\-_]/, '').to_sym
  end

  ##
  # Ensure a given +file+ exists. Uses File.file? internally.
  # Params:
  # +file+:: filepath string to check.

  def ensure_exists(file)
    if not File.file?(file)
      throw Exception.new("No #{ File.extname(file) } file found at #{ file }. Please ensure it exists, or that you have transpiled the necessary files.")
    else
      file
    end
  end

  ##
  # Replace a +file+'s extension with a +new_extension+. New extension must include the period.
  # Params:
  # +file+:: filename string
  # +new_extension+:: extension string - must include period

  def change_extension(file, new_extension)
    file.sub(/\.[a-zA-Z0-9]+\z/, new_extension)
  end

  ##
  # Check if a given +file+ is an svg.
  # Params:
  # +file+:: filename string

  def is_svg?(file)
    /\.svg\z/.match?(file)
  end

end

