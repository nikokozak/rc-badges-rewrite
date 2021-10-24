require_relative "../framework/tags.rb"
require 'fileutils'

describe Tags do

  describe "tree" do

    before :all do
      FileUtils.mkdir_p("tag_tests")
      FileUtils.mkdir_p("tag_tests/tag_1")
      FileUtils.mkdir_p("tag_tests/tag_2")
      File.write("tag_tests/tag_1/one.svg", "svg content")
      File.write("tag_tests/tag_2/two.svg", "svg content")
      File.write("tag_tests/tag_1/one.css", "css content")
      File.write("tag_tests/tag_2/two.css", "svg content")
    end

    before :each do
      @tags = Tags.new("tag_tests")
    end

    it "should create a hash tree" do
      expect(@tags.tree.is_a? Hash).to be true
    end

    it "should have parent folders as keys" do
      tree = @tags.tree
      expect(tree[:tag1]).to be_truthy
      expect(tree[:tag2]).to be_truthy
    end

    it "should have base directory as key if not nested" do
      File.write("tag_tests/one.svg", "svg_content")
      File.write("tag_tests/one.css", "css_content")

      tree = @tags.tree

      expect(tree[:tagtests]).to be_truthy
      expect(tree[:tag1]).to be_truthy
      expect(tree[:tag2]).to be_truthy
    end

    it "should have nodes with correct non-nil content" do
      tree = @tags.tree
      tree.each do |key, nodes| 
        nodes.each do |node|
          expect(node[:title]).to be_truthy
          expect(node[:basename]).to be_truthy
          expect(node[:svg_path]).to be_truthy
          expect(node[:svg_contents]).to be_truthy
          expect(node[:path]).to be_truthy
          expect(node[:category]).to be_truthy
        end
      end
    end

    it "should have categories as symbols" do
      tree = @tags.tree
      tree.each do |key, nodes| 
        nodes.each do |node|
          expect(node[:category].is_a? Symbol).to be true
        end
      end
    end

    it "should throw an error if missing css file" do
      FileUtils.rm("tag_tests/tag_1/one.css")
      expect { tree = @tags.tree }.to raise_error(Exception)
    end

    after :all do
      FileUtils.rm_rf("tag_tests")
    end

  end

end
