require_relative 'sass.rb'
require 'erb'
require 'fileutils'

class Page
  def initialize(title="Home")
    @index = "templates/index_template.erb"
    @tag = "templates/tag_template.erb"
    @categories = Sass.new('test').tree
  end

  def render(file: @index, env: {})
    template = ERB.new(File.read(file))
    template.result_with_hash(env)
  end
end

def render(file, env)
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

result = Page.new.render(env: {categories: Sass.new('test').tree, render: :render})
write_safe("index.html", result)

