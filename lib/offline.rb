require 'tilt/erubis'

class TemplateEngine
  def initialize(template,you=nil,me=nil,**extra)
    me or me = Socket.gethostname
    you or you = me
    @template = template
    @penv = Pixie::Env.new(you, me)
    @me = @penv.me
    @you = @penv.you
    @pixiemaster = @penv.pixiemaster
    @puppetmaster = @penv.puppetmaster
    @subnet = @penv.subnet

    @renderer = Tilt::ERBTemplate.new(@template)
    @extra = extra
  end

  def run
    puts self.render
  end

  def render
    @renderer.render(self)
  end

  def write(filename)
    File.open(filename, 'w') { |file| file.write(self.render) }
  end
end

module Util
  def self.mkdir(d)
    Dir.mkdir(d) unless Dir.exists?(d)
    Dir.new d
  end
end
