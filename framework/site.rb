require_relative 'sass.rb'
require_relative 'tags.rb'
require_relative 'buster.rb'
require_relative 'renderer.rb'

class Site

  ##
  # The site instance takes in parameters representing the various folders
  # it needs to build. Most importantly, the +out+ option dictates where the site
  # is built to (default: "dist").
  # Params:
  # +templates+:: the templates folder (for things like index.html)
  # +styles+:: the styles folder for our page
  # +dist+:: where to build the site
  # +tags+:: where tags are to be found (see the +Tags+ class for more info)

  def initialize(templates:"templates", styles: "styles", out: "dist", tags: "tags")
    @templates = templates
    @styles = styles
    @out = out
    @tags = tags
  end

  ##
  # Builds the site

  def build

    # Get the tree representation of our tags
    tags = Tags[@tags].build

    # Render our styles 
    rendered_styles = Sass[@styles].render(out: @out)

    # Cache-bust our rendered styles (do this before, otherwise we get issues with
    # live-server and the listener).
    busted = Buster.new(rendered_styles).bust(preserve_original: false)

    # Render our templates, passing in our tags as data
    rendered = Renderer[@templates].render(out: @out, env: {tags: tags})

    busted.replace_in(rendered)


  end

end

#Site.new.build
