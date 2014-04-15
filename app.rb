require 'bundler'
Bundler.require

SITE_TITLE = "Sinatra app"

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

# require models
require_relative "models/user"
require_relative "models/article"
require_relative "models/comment"

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize
# automatically create the tables
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!

if User.count == 0
  @user = User.create(email: "admin@it.works")
  @user.password = "admin"
  @user.save
end

class SinatraApp < Sinatra::Base

  configure do
    # enable :sessions
    use Rack::Session::Cookie, secret: "nothingissecretontheinternet"
    use Rack::Flash, :sweep => true, accessorize: [:error, :success]
    register Sinatra::Partial
  end

  configure :development do
    register Sinatra::Reloader
    enable :reloader
  end

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['email'] && params['password']
    end

    def authenticate!
      user = User.first(email: params['email'])
      # binding.pry
      if user.nil?
        fail!("The email you entered does not exist.")
        env['warden.message'] = ""
      elsif user.authenticate(params['password'])
        env['warden.message'] = "Successfully Logged In"
        success!(user)
      else
        fail!("Could not log in")
      end
    end

  end

  helpers do

    def warden_handler
      env['warden']
    end

    def current_user
      warden_handler.user
    end

    def check_authentication
      redirect '/login' unless warden_handler.authenticated?
    end

  end

  #auth

  post '/login' do
    env['warden'].authenticate!
    flash.success = env['warden'].message
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash.success = 'Successfully logged out'
    redirect '/'
  end

  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash.error = env['warden'] || "You must log in"
    redirect '/auth/login'
  end

  get '/login' do
    haml :'account/login'
  end

  #account

  get '/signup' do
    haml :'account/signup'
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

  # users, only admin

  #list of users
  get '/admin/users' do
    @users = User.all
    haml :'users/list'
  end

  # homepage

  get '/' do
    @title = 'Welcome!'
    haml :index, :locals => {:title => @title}
  end

  # about

  get '/about' do
    @title = 'About'
    haml :about
  end

  #articles

  #list of articles
  get '/articles' do
    @title = 'List of articles'
    @articles = Article.all(:order => [ :id.desc ], :ispublic => true)
    haml :list
  end

  #show an article
  get '/articles/:id' do
    @article = Article.get params[:id]
    @comment = Comment.new
    haml :show, :locals => {
      :action => "/comment/create/#{@article.id}"
    }
  end

  #admin

  #list of articles
  get '/admin/articles' do
    check_authentication
    @title = 'List of articles'
    @articles = Article.all(:order => [ :id.desc ])
    haml :admin_list
  end

  #form for new article
  get '/admin/articles/new' do
    check_authentication
    @article = Article.new
    haml :new, :locals => {
      :action => '/admin/articles/create'
    }
  end

  #create an article
  post '/admin/articles/create' do
    check_authentication
    # article = Article.create(:title => params[:title], :body => params[:body])
    @article = Article.new
    @article.attributes = params['article']
    if @article.valid?
      @article.save
      redirect "/admin/articles/#{@article.id}"
    else
      haml :new, :locals => {
        :action => '/admin/articles/create'
      }
    end
  end

  #show an article
  get '/admin/articles/:id' do
    check_authentication
    @article = Article.get params[:id]
    @comment = Comment.new
    haml :admin_show
  end

  #form to edit article
  get '/admin/articles/:id/edit' do |id|
    check_authentication
    @article = Article.get(id)
    haml :edit, :locals => {
      :action => "/admin/articles/#{@article.id}/update"
    }
  end

  # Edit a article
  post '/admin/articles/:id/update' do |id|
    check_authentication
    @article = Article.get(id)

    if @article.update params[:article]
     redirect "/admin/articles/#{id}"
    else
      haml :edit, :locals => {
        :action => '/admin/articles/#{@article}/edit'
      }
    end
  end

  # publish a article
  post '/admin/articles/:id/publish' do |id|
    check_authentication
    article = Article.get(id)
    article.ispublic = params[:ispublic]
    content_type :json
    if article.valid?
      article.save
      { :id => id, :ispublic => article.ispublic }.to_json
    else
      status 400
      "Article not valid"
    end
    # redirect "/admin/articles/#{id}"
  end

   # Delete a article
  post '/admin/articles/:id/destroy' do |id|
    check_authentication
    article = Article.get(id)
    article.destroy

    content_type :json
    { :id => id }.to_json
    # redirect "/admin/articles"
  end

  #comments

  #create an comment
  post '/comment/create/:article_id' do
    # article = Comment.create(:body => params[:body], :post_id => params[:article_id])
    @article = Article.get(params[:article_id])

    @comment = Comment.new
    @comment.attributes = params[:comment]
    @comment.article = @article

    if @comment.valid? # it also checks article.valid?
      @comment.save
      redirect "/articles/#{@article.id}"
    else
      haml :show, :locals => {
        :action => "/comment/create/#{@article.id}"
      }
    end

  end

  #exceptions

  not_found do
    halt 404, 'Page not found'
  end

end