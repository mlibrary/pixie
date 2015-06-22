require 'byebug'

class PixieApp < Sinatra::Base
  get '/debug' do
    byebug
    "OK"
  end

  get '/debug/erb' do
    erb :debug
  end
end