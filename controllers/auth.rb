class SinatraApp < Sinatra::Base
  #auth

  get '/login' do
    haml :'account/login'
  end

  post '/login' do
    # call warden strategies
    env['warden'].authenticate!
    # warden message
    flash[:success] = env['warden'].message || "Successfull login"
    # came from protected page?
    if session[:return_to] == '/login' || session[:return_to].nil?
      redirect "/"
    else
      redirect session[:return_to]
    end
  end

  # accessing unauthenticated user to protected path
  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash[:error] = env['warden'].message  || 'Please login to continue'
    redirect '/login'
  end

  get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end
end