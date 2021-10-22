require 'pathname'

# RUNS FROM THE SHELL CWD

class Sass

  def self.filename(file)
    /\A(.*\/)?([a-zA-Z0-9\-_]*)\.s(a|c)ss\z/.match(file)[2]
  end

  def self.is_sass?(file)
    /\.s(a|c)ss\z/.match(file) ? true : false
  end

  def self.is_mixin?(file)
    /\A(.*\/)?_.*\.s(a|c)ss\z/.match(file) ? true : false
  end

  def self.call_sass(input_file)
    input_path = Pathname.new(input_file)

    fh = input_path.dirname
    fo = File.join(fh, Sass.filename(input_file) + '.css')
    %x{sass #{input_file} #{fo}}
    p "Sass compiled #{ input_file } -> #{ fo }"
  end

  def self.run(file_path='.')
    Dir['**/*', base: file_path].each do |f|
      f = File.join(file_path, f)

      File.file?(f) && is_sass?(f) && (not is_mixin? f) ? call_sass(f) : next
    end
  end

end
