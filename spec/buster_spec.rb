require_relative '../commander/buster.rb'
require 'fileutils'

describe Buster do

  describe "initialize" do
    it "should throw on wrong input" do
      expect { Buster.new("abc") }.to raise_error
    end

    it "should create a new instance with a list of files" do
      files = ["hello.css", "/test/another.html"]
      buster = Buster.new(files)
      expect(buster.files).to equal(files)
    end
  end

  describe "bust" do

    before :all do
      FileUtils.mkdir_p("buster_test")
    end

    before :each do
      File.write("buster_test/test.css", "some content")
    end

    it "should create a new file with a hash prefix" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust
      expect(Dir['buster_test/*_test.css'].empty?).to be false
    end

    it "should change the hash prefix upon content change" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust
      first_busted_files = Dir['buster_test/*_test.css']
      File.write("buster_test/test.css", "some different content")
      buster.bust
      new_busted_files = Dir['buster_test/*_test.css']

      expect(first_busted_files).not_to match_array(new_busted_files)
    end

    it "should remove old busts when creating a new one" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust
      first_busted_files = Dir['buster_test/*_test.css']
      File.write("buster_test/test.css", "some different content")
      buster.bust
      new_busted_files = Dir['buster_test/*_test.css']
      
      first_busted_files.each { |f| expect(File.exist? f).to be false }  
      new_busted_files.each { |f| expect(File.exist? f).to be true }
    end

    it "should write bust files to a given destination" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust("buster_test/dest")

      expect(Dir['buster_test/dest/*_test.css'].empty?).to be false
    end

    it "should remove previous bust files in a given destination" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust("buster_test/dest")
      first_busted_files = Dir['buster_test/dest/*_test.css']
      File.write("buster_test/test.css", "some different content")
      buster.bust("buster_test/dest")
      new_busted_files = Dir['buster_test/dest/*_test.css']
      
      first_busted_files.each { |f| expect(File.exist? f).to be false }  
      new_busted_files.each { |f| expect(File.exist? f).to be true }
    end

    it "should not preserve a tree if only an output destinatin given" do
      FileUtils.mkdir_p("buster_test/nested")
      File.write("buster_test/nested/nested_test.css", "some nested content")
      buster = Buster.new(['buster_test/nested/nested_test.css'])
      buster.bust("buster_test/dest")
      busted_files = Dir['buster_test/dest/*_nested_test.css']

      expect(File.exist?("buster_test/dest/nested")).to be false
      busted_files.each { |f| expect(File.exist? f).to be true }  
    end

    it "should preserve a tree if the setting is provided" do
      FileUtils.mkdir_p("buster_test/nested")
      File.write("buster_test/nested/nested_test.css", "some nested content")
      buster = Buster.new(['buster_test/nested/nested_test.css'])
      buster.bust("buster_test/dest", true)
      busted_files = Dir['buster_test/dest/nested/*_nested_test.css']

      p Dir['buster_test/dest/**/*']

      expect(File.exist?("buster_test/dest/nested")).to be true
      busted_files.each { |f| expect(File.exist? f).to be true }  
    end

    it "should create populate the map with original->busted references" do
      buster = Buster.new(['buster_test/test.css'])
      buster.bust
      expect(/[a-z0-9]{6}_test.css/.match?(buster.map["test.css"])).to be true
    end

    after :each do
      FileUtils.rm_rf(Dir['buster_test/**'])
    end

    after :all do
      FileUtils.rm_rf("buster_test")
    end
  end
  
  describe "replace_in" do

    before :all do
      FileUtils.mkdir_p("buster_test")
      File.write("buster_test/test.css", "some content")
      File.write("buster_test/test.html", "test.css")
    end

    before :each do
      @buster = Buster.new(Dir['buster_test/*.css'])
      @buster.bust
    end

    it "should replace references to busted files in files" do
      @buster.replace_in(Dir['buster_test/*.html'])
      new_contents = File.read('buster_test/test.html')
      expect(new_contents).to eq(@buster.map["test.css"])
    end

    after :each do
      FileUtils.rm(Dir['buster_test/*_test.css'])
    end

    after :all do
      FileUtils.rm_rf("buster_test")
    end
  end

  describe "busted?" do

    before :each do
      @busted = Buster.new(['whatev'])
    end

    it "should detect a busted file" do
      filename_1 = "this/is/a/busted/123aac_file.css"
      filename_2 = "4588ab_also.css"
      filename_3 = "34299a_this_too.css"
      filename_4 = "not/this.css"
      filename_5 = "and_not_this.css"
      filename_6 = "or234_this.css"

      expect(@busted.busted?(filename_1)).to be true
      expect(@busted.busted?(filename_2)).to be true
      expect(@busted.busted?(filename_3)).to be true
      expect(@busted.busted?(filename_4)).to be false
      expect(@busted.busted?(filename_5)).to be false
      expect(@busted.busted?(filename_6)).to be false
    end
  end

end
