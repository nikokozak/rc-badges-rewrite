require 'pathname'

# RUNS FROM THE SHELL CWD

class Sass
  attr_reader :folder

  def initialize(folder='.')
    @folder = File.join(Dir.pwd, folder)
  end

  def self.filename(file)
    /([a-zA-Z0-9\-_]*)\.s(a|c)ss\z/.match(file)[1]
  end

  def self.is_sass?(file)
    /\.s(a|c)ss\z/.match(file) ? true : false
  end

  def self.call_sass(input_file, output_file=nil)
    input_path = Pathname.new(input_file)

    fh = input_path.dirname
    fo = File.join(fh, Sass.filename(input_file) + '.css')
    %x{sass #{input_file} #{fo}}
  end

  def run
    Sass.run(@folder) 
  end

  def self.run(file_path='.')
    file_path = Pathname.new(file_path)

    if file_path.file? && is_sass?(file_path.to_s)
      Sass.call_sass(file_path.to_s)
    elsif file_path.directory?
      Dir.chdir(file_path) do
        Dir.children(".").each { |f| Sass.run(File.join(file_path, f)) } 
      end
    end
  end

  def tree
    Sass.tree(@folder)
  end

  def self.tree(file_path='.')
    file_path = Pathname.new(file_path)

    result = {}

    Dir.chdir(file_path) do
      Dir['**/*'].each do |f|
        if File.file?(f) && is_sass?(f)
          node = Sass.build_node(file_path, f)
          cat = node[:category]
          result[cat] = (result[cat] || []).push(node)
        end
      end
    end
    
    result
  end

  private

  def self.build_node(base_path, file)
    path = Pathname.new(file)
    category = Sass.parent_folder(path) == "." ? base_path : Sass.parent_folder(path)
    filename = Sass.filename(file)
    title = Sass.filename_to_title(filename)
    style = File.read(File.join(path.dirname, filename + ".css"))
    svg_file = File.join(path.dirname, filename + ".svg")

    { title: title,
      filename: filename,
      style: style,
      svg_file: svg_file,
      path: path.to_s,
      category: category }
  end

  def self.parent_folder(pathname)
    pathname.dirname.basename.to_s
  end

  def self.filename_to_title(filename)
    filename.gsub(/[\-_]/, " ").capitalize
  end

end
