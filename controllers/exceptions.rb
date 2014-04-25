class SinatraApp < Sinatra::Base
  #exceptions

  not_found do
    halt 404, 'Page not found'
  end
end