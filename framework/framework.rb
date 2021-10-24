require 'yaml'
require_relative 'site.rb'

SETTINGS_FILE = "settings.yml"

##
# Make sure you run this from the root folder of the project.
# Usage:
# ruby framework.rb (dev|build)

class Framework

  def self.run
    mode = parse_mode
    settings = parse_settings(SETTINGS_FILE)

    Site.new(templates: settings["templates_folder"],
             styles: settings["styles_folder"],
             out: settings["out_folder"],
             tags: settings["tags_folder"]).build
  end

  private

  def self.parse_mode
    mode = ARGV[0] || "dev"
    if ((mode != "dev") && (mode != "prod"))
      p option_parser.help
      exit 1
    end

    mode
  end

  def self.parse_settings(file)
    begin
      YAML.load_file(file)
    rescue Psych::SyntaxError => ex
      p ex.message
      exit 1
    end
  end

end

Framework.run
