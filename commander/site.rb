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
  def render_internal(file, env={})
    template = ERB.new(File.read(file))
    b = binding
    env.each do |key, val| 
      b.local_variable_set(key.to_sym, val)
    end
    template.result(b)
  end

  def write_safe(file, content)
    copy_to([file], '.safe')

    File.write(file, content)
  end

  private

  def filename(f)
    /\A(.*\/)?(.+)\..+/.match(Pathname.new(f).basename.to_s)[2]
  end

  def copy_to(arr_of_files, dist_folder, bust=false)
    FileUtils.mkdir_p(dist_folder) if not File.exist?(dist_folder)

    arr_of_files.reduce({}) do |result, f|
      if File.exist? f
        out = bust ? File.join(dist_folder, cache_bust_filename(f)) : dist_folder
        FileUtils.cp(f, out)
        p "Copied file #{ f } -> #{ dist_folder }"
        result[/\A(.*\/)(.*\.[a-zA-Z0-9]+)\z/.match(f)[2]] = bust ? cache_bust_filename(f) : f
        result
      else
        result
      end
    end
  end

  def process_styles(folder, out)
    Sass.run(folder)
    styles = Dir['*.css', base: folder].map { |f| File.join(folder, f) }
    busted = copy_to(styles, out, true)
    update_busted_links(busted, out)
  end

  def cache_bust_filename(path_to_file)
    require 'digest'

    hash = Digest::MD5.hexdigest File.read(path_to_file)
    filename = /\A(.*\/)?(.*\.[a-zA-Z0-9]+\z)/.match(path_to_file)[2]
    hash[0...6] + "_" + filename 
  end

  def update_busted_links(original_and_busted_hash, out)
    html_files = Dir['**/*.html', base: out].map { |f| File.join(out, f) } 
    original_and_busted_hash.each do |original, busted|
      filename = /\A(.*\/)?(.*\.[a-zA-Z0-9]+\z)/.match(original)[2]
      html_files.each do |file|
        html = File.read(file)
        File.write(file, html.gsub(/#{original}/, busted))
        # p "Updated #{ original } to #{ busted } in #{ file }"
      end
    end
  end

end

Site.new.render
