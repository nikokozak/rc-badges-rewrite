require_relative 'sass.rb'

class Tags
  def initialize(folder="tags")
    @folder = folder
  end

  def process
    p "Processing tags in folder '#{ @folder }'"
    Sass.run(@folder)
    p "Finished processing tags in folder '#{ @folder }'"
  end

  def tree
    Dir.chdir(@folder) do
      Dir['**/*'].reduce({}) do |result, f|
        if File.file?(f) && Sass.is_sass?(f)
          node = build_node(f)
          cat = category_from_string(node[:category])
          result[cat] = (result[cat] || []).push(node)
          result
        else
          result
        end
      end
    end
  end

  private

  def build_node(file)
    filepath = Pathname.new(file)
    category = parent_folder(filepath) == "." ? @folder : parent_folder(filepath)
    filename = filename(file)
    title = filename_to_title(filename)
    css_path = check_css(File.join(filepath.dirname, filename + ".css"))
    style = File.read(css_path)
    svg_path = check_svg(File.join(filepath.dirname, filename + ".svg"))
    svg_contents = File.read(svg_path)

    { title: title,
      filename: filename,
      style: style,
      svg_file: svg_path,
      svg_contents: svg_contents,
      path: filepath.to_s,
      category: category }
  end

  def filename(file)
    /([a-zA-Z0-9\-_]+)\..+\z/.match(file)[1]
  end

  def parent_folder(pathname)
    pathname.dirname.basename.to_s
  end

  def filename_to_title(filename)
    filename.gsub(/[\-_]/, " ").capitalize
  end

  def category_from_string(cs)
    cs.gsub(/[\-_]/, '').to_sym
  end

  def check_css(css_path)
    if not File.exist?(css_path)
      throw Error.new("No css style found for file #{ file }. Please process and try again.")
    else
      css_path
    end
  end

  def check_svg(svg_path)
    if not File.exist?(svg_path)
      throw Error.new("No svg file found for #{ file }. Please include one and try again.")
    else
      svg_path
    end
  end

end

tags = Tags.new
tags.process
pp tags.tree

