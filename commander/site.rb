require_relative 'sass.rb'
require_relative 'tags.rb'
require_relative 'buster.rb'
require_relative 'renderer.rb'

class Site

  def initialize(name:"Home", templates:"templates", styles: "styles", out: "dist", tags: "tags")
    @templates = templates
    @styles = styles
    @name = name
    @out = out
    @tags = tags
  end

  def build
    Sass[@tags].render
    tags = Tags[@tags].tree

    rendered = Renderer[@templates].render(out: @out, env: {tags: tags})
    rendered_styles = Sass['styles'].render(out: @out + "/styles")

    Buster[rendered_styles].bust(preserve_original: false).replace_in(rendered)
  end

end
