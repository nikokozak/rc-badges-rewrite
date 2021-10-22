require_relative 'sass.rb'
require_relative 'tags.rb'
require 'erb'
require 'fileutils'

class Site

  def initialize(name:"Home", templates:"templates")
    @queue = Dir['[^_]*.erb', base: templates].map { |f| File.join(templates, f) }

    tags = Tags.new('tags')
    tags.process
    @categories = tags.tree
  end

  def render(files: @queue, out: "./dist", styles: 'styles')
    FileUtils.mkdir(out) if not File.exist? out 

    files.each do |f|
      template = ERB.new(File.read(f))
      result = template.result(binding)
      filename = filename(f)
      outfile = File.join(out, filename + ".html")

      write_safe(outfile, result)

      p "Transformed #{f} -> #{outfile}"
    end

    process_styles(styles, out)
  end

  # Render function to use in nested templates
  def render_internal(file, env)
    template = ERB.new(File.read(file))
    template.result_with_hash(env)
  end

  def write_safe(file, content)
    copy_to([file], '.safe')

    File.write(file, content)
  end

  private

  def filename(f)
    /\A(.*\/)?(.+)\..+/.match(Pathname.new(f).basename.to_s)[2]
  end

  def copy_to(arr_of_files, dist_folder)
    FileUtils.mkdir_p(dist_folder) if not File.exist?(dist_folder)

    arr_of_files.each do |f|
      if File.exist? f
        FileUtils.cp(f, dist_folder, preserve:false)
        p "Copied file #{ f } -> #{ dist_folder }"
      end
    end
  end

  def process_styles(folder, out)
    Sass.run(folder)
    styles = Dir['*.css', base: folder].map { |f| File.join(folder, f) }
    copy_to(styles, out)
  end

end

Site.new.render


