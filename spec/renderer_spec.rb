require_relative '../framework/renderer.rb'
require 'fileutils'

describe Renderer do

  before :all do
    FileUtils.mkdir_p("render_tests/nested")
    index_content = "<h1>Hello</h1><%= 1 + 2 %>"
    nested_content = "<p>nested <%= 5 + 6 %></p>"
    File.write("render_tests/index.erb", index_content)
    File.write("render_tests/nested/_nested.erb", nested_content)
  end

  describe "[]" do
    it "initializes a renderer with a queue" do
       renderer = Renderer['render_tests'] 
       expect(renderer.queue.empty?).to be false
    end
  end

  describe "render" do
    it "renders template files as siblings" do
      Renderer['render_tests'].render
      expect(File.exist? "render_tests/index.html").to be true
    end

    it "does not render _template files" do
      Renderer['render_tests'].render
      expect(File.exist? "render_tests/nested/_index.html").to be false
    end

    it "correctly renders self-contained content" do
      Renderer['render_tests'].render
      expected = "<h1>Hello</h1>3"
      expect(File.read "render_tests/index.html").to eq(expected)
    end

    it "correctly renders self-contained content to new dir" do
      Renderer['render_tests'].render(out: "./render_dist")

      expect(File.exist? "./render_dist/index.html").to be true
      expect(File.exist? "./render_tests/index.html").to be false
      FileUtils.rm_rf("./render_dist")
    end

    it "correctly preserves folder structure in new dir" do
      File.write("render_tests/nested/another.erb", "<p>Hi</p>")
      Renderer['render_tests'].render(out: "./render_dist")

      expect(File.exist? "./render_dist/index.html").to be true
      expect(File.exist? "./render_tests/index.html").to be false
      expect(File.exist? "./render_dist/nested/another.html").to be true
      expect(File.exist? "./render_tests/nested/another.html").to be false
      FileUtils.rm_rf("./render_dist")
    end
  end

  describe "render_internal" do
    it "correctly renders references" do
      index_content = "<%= render_internal \"nested/_nested.erb\" %>"
      File.write('render_tests/index.erb', index_content)
      result = Renderer['render_tests'].render_internal('index.erb')
      expect(result).to eq("<p>nested 11</p>")
    end

    it "correctly passes data to references" do
      index_content = "<%= render_internal \"nested/_nested.erb\", {a: 'data'} %>"
      File.write('render_tests/index.erb', index_content)
      nested_content = "<p>nested <%= a %></p>"
      File.write('render_tests/nested/_nested.erb', nested_content)
      result = Renderer['render_tests'].render_internal('index.erb')
      expect(result).to eq("<p>nested data</p>")
    end
  end

  after :each do
    FileUtils.rm(Dir['render_tests/**/*.html'])
  end

  after :all do
    FileUtils.rm_rf("render_tests")
  end

end
