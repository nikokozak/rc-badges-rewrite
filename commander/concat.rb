require_relative 'sass.rb'
require 'erb'

tree = Sass.new('test').tree
p tree

template = ERB.new(File.read("commander/template.erb"))
result = template.result_with_hash(categories: tree)

File.write("template_out.html", result)




