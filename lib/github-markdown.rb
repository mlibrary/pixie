require 'tilt/template'
require 'github/markdown'

module Tilt
  class GitHubTemplate < Template
    self.default_mime_type = 'text/html'

    def prepare
      @engine = nil

      if options[:gfm]
        @output = GitHub::Markdown.render_gfm(data)
      else
        @output = GitHub::Markdown.render(data)
      end
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end

    def allows_script?
      false
    end
  end
end