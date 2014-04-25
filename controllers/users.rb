class SinatraApp < Sinatra::Base
  # users, only admin

  #list of users
  get '/admin/users' do
    @users = User.all
    haml :'users/list'
  end

end