class SinatraApp < Sinatra::Base
  #account

  get '/signup' do
    @user = User.new
    haml :'account/signup'
  end

  # create a user
  post '/signup' do
    @user = User.new(:email => params[:email], :password => params[:password])

    if @user.save
      flash.success = 'Successfully created account'
      haml :index
    else
      flash.success = 'Fill fields to register'
      haml :'account/signup'
    end
  end


  #show logged user
  get '/account' do
    # @user = User.get params[:id]
    @user = current_user
    haml :'account/show'
  end

  #edit logged user
  get '/account/edit' do
    @user = current_user
    haml :'account/edit'
  end

  #edit logged user
  post '/account/update' do
    @user = current_user
    flash.error = "Not implemented yet"
    haml :'account/show'
  end
end