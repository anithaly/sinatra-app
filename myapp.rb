require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'sinatra/partial'
require 'sinatra/contrib'
# require "sinatra/reloader" if development?
require 'json'
# require 'rack-flash'

require 'data_mapper'
require 'dm-core'
require 'dm-migrations'
require 'bcrypt'

require 'pry'

# use Rack::Flash
# somewhere in a haml view:
# = flash[:notice]
# = flash[:error]

# use Rack::Session::Cookie, :secret => 'sth secret'
# enable :sessions

# flash messages
# use Rack::Flash


SITE_TITLE = "Sinatra app"

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Article
    include DataMapper::Resource
    property :id, Serial
    property :title, String, :required => true, :length => 3..255
    property :body, Text, :required => true
    property :ispublic, Boolean, :default  => false
    property :created_at, DateTime
    has n, :comments
    # belongs_to :user
end

class Comment
    include DataMapper::Resource
    property :id, Serial
    property :body, Text, :required => true
    property :created_at, DateTime
    # belongs_to :user
    belongs_to :article
    # property   :article_id, Integer, :required => false
end

# class User
#     include DataMapper::Resource
#     property :id, Serial, :key => true
#     property :name, String, :length => 3..50
#     property :email, String
#     property :password, BCryptHash
#     property :created_at, DateTime
# end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize
# automatically create the tables
DataMapper.auto_upgrade!

# Article.auto_upgrade!
# Comment.auto_upgrade!
# User.auto_upgrade!

# Article.auto_migrate!
# Comment.auto_migrate!
# User.auto_migrate!

configure do
  set :haml, :format => :html5, :layout_engine => :haml, :layout => :layout
end


# routes
#
#
# users
#
# userTable = {}

# helpers do

#   def login?
#     if session[:username].nil?
#       return false
#     else
#       return true
#     end
#   end

#   def username
#     return session[:username]
#   end

# end

# get "/signin" do
#   haml :signin
# end

# get "/signup" do
#   haml :signup
# end

# post "/signup" do
#   password_salt = BCrypt::Engine.generate_salt
#   password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)

#   #ideally this would be saved into a database, hash used just for sample
#   userTable[params[:username]] = {
#     :salt => password_salt,
#     :passwordhash => password_hash
#   }

#   session[:username] = params[:username]
#   redirect "/"
# end

# post "/login" do
#   if userTable.has_key?(params[:username])
#     user = userTable[params[:username]]
#     if user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
#       session[:username] = params[:username]
#       redirect "/"
#     end
#   end
#   haml :error
# end

# get "/logout" do
#   session[:username] = nil
#   redirect "/"
# end

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
  # @article = Article.find params[:id]
  @article = Article.get params[:id]
  @comment = Comment.new
  haml :show, :locals => {
    :action => "/comment/create/#{@article.id}"
  }
end

#admin

#list of articles
get '/admin/articles' do
  @title = 'List of articles'
  @articles = Article.all(:order => [ :id.desc ])
  haml :admin_list
end

#form for new article
get '/admin/articles/new' do
  @article = Article.new
  haml :new, :locals => {
    :action => '/admin/articles/create'
  }
end

#create an article
post '/admin/articles/create' do
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
  @article = Article.get params[:id]
  @comment = Comment.new
  haml :admin_show
end

#form to edit article
get '/admin/articles/:id/edit' do |id|
 @article = Article.get(id)
 haml :edit, :locals => {
  :action => "/admin/articles/#{@article.id}/update"
 }
end

# Edit a article
post '/admin/articles/:id/update' do |id|
 @article = Article.get(id)
 @article.update params[:article]

 redirect "/admin/articles/#{id}"
end

# publish a article
post '/admin/articles/:id/publish' do |id|
 article = Article.get(id)
 article.ispublic = params[:ispublic]
 article.save

 content_type :json
 { :id => id, :ispublic => article.ispublic }.to_json
 # redirect "/admin/articles/#{id}"
end

 # Delete a article
post '/admin/articles/:id/destroy' do |id|
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

#users

# DEFAULT ROUTES:

# get '/login'
# get '/logout'
# get '/signup'
# get/post '/users'
# get '/users/:id'
# get/post '/users/:id/edit'
# get '/users/:id/delete'

not_found do
  halt 404, 'Page not found'
end

=begin
  comments
=end