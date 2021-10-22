require_relative 'sass.rb'
require 'erb'
require 'fileutils'

class Site

  def initialize(name:"Home", templates:"templates")
    @queue = Dir['[^_]*.erb', base: templates].map { |f| File.join(templates, f) }
    @categories = Sass.new('tags').tree
  end

  def render(files: @queue, out: "./dist")
    FileUtils.mkdir(out) if not File.exist? out 

    files.each do |f|
      template = ERB.new(File.read(f))
      result = template.result(binding)
      filename = filename(f)
      outfile = File.join(out, filename + ".html")
      write_safe(outfile, result)

      p "Transformed #{f} -> #{outfile}"
    end
  end

  # Render function to use in nested templates
  def render_internal(file, env)
    template = ERB.new(File.read(file))
    template.result_with_hash(env)
  end

  def write_safe(file, content)
    FileUtils.mkdir_p('.safe') if not File.exist?('.safe')

    if File.exist? file
      FileUtils.cp(file, ".safe/", preserve: false)
    end

    File.write(file, content)
  end

  private

  def filename(f)
    /(.+)\..+/.match(Pathname.new(f).basename.to_s)[1]
  end

end

Site.new.render


