require_relative '../lib/pixie'
require 'tilt/erubis'

class TemplateEngine
  def initialize(template,you,me=you)
    @template = template
    @penv = Pixie::Env.new(you, me)
    @me = @penv.me
    @you = @penv.you
    @pixiemaster = @penv.pixiemaster
    @puppetmaster = @penv.puppetmaster

    @renderer = Tilt::ERBTemplate.new(@template)
  end

  def run
    puts @renderer.render(self)
  end
end

you = Socket.gethostname
te = TemplateEngine.new(ARGV[0],you)
te.run