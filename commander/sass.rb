require 'pathname'

# RUNS FROM THE SHELL CWD

class Sass

  def self.filename(file)
    /([a-zA-Z0-9\-_]*)\.s(a|c)ss\z/.match(file)[1]
  end

  def self.is_sass?(file)
    /\.s(a|c)ss\z/.match(file) ? true : false
  end

  def self.call_sass(input_file)
    input_path = Pathname.new(input_file)

    fh = input_path.dirname
    fo = File.join(fh, Sass.filename(input_file) + '.css')
    %x{sass #{input_file} #{fo}}
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

end
