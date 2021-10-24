require_relative '../commander/sass.rb'
require 'fileutils'

describe Sass do

  # Disable stdout during tests
  original_stderr = $stderr
  original_stdout = $stdout
  before :all do 
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end

  # Re-enable stdout after tests
  after :all do 
    $stderr = original_stderr
    $stdout = original_stdout
  end 

  describe "is_css?" do
    it "correctly identifies a css file" do
      expect(Sass.is_css?("hey/this/is/a/css_file.css")).to be true
    end

    it "correctly identifies a non-css file" do
      expect(Sass.is_css?("hey/this/is/a/css_file.svg")).to be false
    end
  end

  describe "is_sass?" do
    it "correctly identifies a sass file" do
      expect(Sass.is_sass?("hey/this/is/a/sass_file.sass")).to be true
      expect(Sass.is_sass?("hey/this/is/a/sass_file.scss")).to be true
    end

    it "correctly identifies a non-sass file" do
      expect(Sass.is_sass?("hey/this/is/a/sass_file.css")).to be false
    end
  end

  describe "is_mixin?" do
    it "correctly identifies a sass mixin file" do
      expect(Sass.is_mixin?("hey/this/is/a/_mixin_file.sass")).to be true
      expect(Sass.is_mixin?("hey/this/is/a/_mixin.scss")).to be true
    end

    it "correctly identifies a non-sass mixin file" do
      expect(Sass.is_mixin?("hey/this/is/a/file.sass")).to be false
      expect(Sass.is_mixin?("hey/this/is/a/file.scss")).to be false
    end
  end

  describe "call_sass" do

    before :all do
      FileUtils.mkdir_p("test_dir")
    end

    before :each do
      sass_content = "a\n\tfont-family: 'Open Sans'"
      File.write("test_dir/test.sass", sass_content)
    end

    it "should create a new css file" do
      Sass.call_sass("test_dir/test.sass")
      expect(File.exist?("test_dir/test.css")).to be true
    end

    it "should create a valid css file" do
      Sass.call_sass("test_dir/test.sass")
      content = File.read("test_dir/test.css")
      target = "a {\n  font-family: \"Open Sans\";\n}"
      expect(content).to include(target)
    end

    it "should fail on non-existant css file" do
      expect { Sass.call_sass("test_dir/atest.sass") }.to raise_error(Exception)
    end

    after :each do
      FileUtils.rm(Dir["test_dir/*.*"])
    end

    after :all do
      FileUtils.rm(Dir["test_dir/*.*"])
      FileUtils.rmdir("test_dir")
    end
    
  end

  describe "run" do

    before :all do
      FileUtils.mkdir_p("test_dir/one")
      FileUtils.mkdir_p("test_dir/two")
      FileUtils.mkdir_p("test_dir/three")
    end

    before :each do
      sass_content = "a\n\tfont-family: 'Open Sans'"
      File.write("test_dir/test.sass", sass_content)
      File.write("test_dir/_test.sass", sass_content)
      File.write("test_dir/one/test.sass", sass_content)
      File.write("test_dir/one/_test.sass", sass_content)
      File.write("test_dir/two/test.sass", sass_content)
      @sass = Sass['test_dir']
    end

    it "should create new css files" do
      @sass.render
      expect(File.exist?("test_dir/test.css")).to be true
      expect(File.exist?("test_dir/one/test.css")).to be true
      expect(File.exist?("test_dir/two/test.css")).to be true
      expect(File.exist?("test_dir/three/test.css")).to be false
    end

    it "should create new css files in output dir" do
      @sass.render(out: "test_dist")
      expect(File.exist?("test_dir/test.css")).to be false
      expect(File.exist?("test_dir/one/test.css")).to be false
      expect(File.exist?("test_dir/two/test.css")).to be false
      expect(File.exist?("test_dir/three/test.css")).to be false
      expect(File.exist?("test_dist/test.css")).to be true
      expect(File.exist?("test_dist/one/test.css")).to be true
      expect(File.exist?("test_dist/two/test.css")).to be true
      expect(File.exist?("test_dist/three/test.css")).to be false
    end

    it "should return a list of new rendered style files" do
      rendered = @sass.render
      expect(rendered).to match_array(['test_dir/test.css', 
                              'test_dir/one/test.css',
                              'test_dir/two/test.css'])
    end

    it "should not process mixins" do
      @sass.render
      expect(File.exist?("test_dir/_test.css")).to be false
      expect(File.exist?("test_dir/one/_test.css")).to be false
    end

    it "should fail on nonexistent dir" do 
      expect { Sass['nonexistent_dir'] }.to raise_error(Exception)
    end

    it "should fail on file input" do 
      expect { Sass["test_dir/test.sass"] }.to raise_error(Exception)
    end

    after :each do
      FileUtils.rm(Dir["test_dir/**/*.*"])
      FileUtils.rm_rf("test_dist")
    end

    after :all do
      FileUtils.rmdir(Dir["test_dir/**"])
      FileUtils.rmdir("test_dir")
    end

  end

end
