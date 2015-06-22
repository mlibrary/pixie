require 'sinatra/base'
require 'sinatra/advanced_routes'
require 'set'
require 'pathname'
require_relative 'lib/pixie'

require './lib/github-markdown'
module Tilt
  register_lazy :GitHubTemplate,  './lib/github-markdown', 'markdown', 'mkd', 'md'
end

class PixieApp < Sinatra::Base
  register Sinatra::AdvancedRoutes

  before do
    # clean junk params
    request.params.each do |k,v|
      v.empty? and request.params.delete(k)
    end

    # populate environment
    @me_override  = request.params['P'] || request.params['pixie']
    @you_override = request.params['S'] || request.params['server']
    me  = @me_override  || request.host
    you = @you_override || request.ip

    @penv = Pixie::Env.new(you, me)
    @me = @penv.me
    @you = @penv.you
    @subnet = @penv.subnet
    @pixiemaster = @penv.pixiemaster
    @puppetmaster = @penv.puppetmaster
    @port = request.port

    if request.params.empty?
      @param_str = ''
    else
      @param_str = '?'+request.params.map{|k,v| "#{k}=#{v}"}.join("&")
    end    
  end

  helpers do
    def fortune
      p = 'Pixie '
      i = [['Imaging ' ,['Installations ','Images ']],['Is ' ,['Installations ','Imaging ']],['Installs ' ,['Installations ','Images ']]].sample
      x = ['eXpedient ','eXcellent '].sample
      e = [['Enhancement',['Installations ','Image ','Imaging ']],['Expertly',['Installations ','Images ','Imaging ']]].sample
      ii = Set.new(i[1]) & Set.new(e[1])
      ii = ii.to_a.sample

      p+i[0]+x+ii+e[0]
    end
  end

  get '/' do
    @menu = []
    PixieApp.each_route do |route|
      if route.verb == "GET"
        @menu.push route.path
      end
    end

    @menu.select!{|i| !/\:/.match(i)}

    Pathname.new(settings.public_folder).children.each do |f|
      name = f.basename.to_s

      next if /^\./.match name # skip dot files

      m = /^(?<base>.*)\.(?<ext>erb)$/.match name
      name = m[:base] if m

      @menu.push "/#{name}"
    end

    haml :index
  end

  get '/:erb' do
    pass unless File.exist?("#{settings.public_folder}/#{params[:erb]}.erb")
    content_type 'text/plain'
    erb :"#{params[:erb]}", :views => settings.public_folder
  end

  get '/:haml' do
    pass unless File.exist?("#{settings.public_folder}/#{params[:haml]}.haml")
    haml :"#{params[:haml]}", :views => settings.public_folder
  end
  
  get '/env' do
    @penv.to_json
  end

  get '/readme' do
    markdown :README, :views => settings.root, :gfm => true
  end

  get '/subnets' do
    Pixie::Subnets.get.to_json
  end

  get '/subnets/each/:var' do
    Pixie::Subnets.get_each_value_of(params['var']).to_json
  end

  get '/servers' do
    'No inventory implimented yet. Try /servers/:server for individual server info.'
  end

  get '/servers/:server' do
    Pixie::Server.new(params['server']).to_json
  end

  not_found do
    halt 404, '{"error":404}'
  end
end

require_relative 'lib/debug' if settings.environment == :development