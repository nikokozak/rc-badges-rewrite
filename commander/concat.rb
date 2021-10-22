require_relative 'sass.rb'
require 'erb'
require 'fileutils'

tree = Sass.new('test').tree

template = ERB.new(File.read("commander/template.erb"))
result = template.result_with_hash(categories: tree)

def write_safe(file, content)
  FileUtils.mkdir_p('.safe') if not File.exist?('.safe')

  if File.exist? file
    FileUtils.cp(file, ".safe/", preserve: false)
  end

  File.write(file, content)
end

write_safe("index.html", result)



