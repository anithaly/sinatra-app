require "bundler/setup"
require 'rubygems'
require "sinatra"
require "sinatra/partial"
require 'sinatra/contrib'
require "sinatra/reloader" if development?
require 'data_mapper' # metagem, requires common plugins too.
require 'dm-core'
require 'dm-migrations'
require 'pry'

SITE_TITLE = "Sinatra app"

enable :sessions

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Article
    include DataMapper::Resource
    property :id, Serial
    # property :user_id, Integer
    property :title, String
    property :body, Text
    property :created_at, DateTime
    has n, :comments
end

class Comment
    include DataMapper::Resource
    property :id, Serial
    # property :user_id, Integer
    belongs_to :article #, :required => false
    # property   :article_id, Integer
    property :body, Text
    property :created_at, DateTime
end

# class User
#     include DataMapper::Resource
#     property :id, Serial
#     property :name, String
#     property :email, String
#     property :created_at, DateTime
# end

DataMapper.auto_upgrade!

# # Perform basic sanity checks and initialize all relationships
# # Call this when you've defined all your models
DataMapper.finalize

# # automatically create the tables
# Article.auto_upgrade!
Article.auto_migrate!
Comment.auto_migrate!
# User.auto_upgrade!

set :haml, :format => :html5, :layout_engine => :haml, :layout => :layout

get '/' do
  @title = 'Welcome!'
  haml :index, :locals => {:title => @title}
end

get '/about' do
  @title = 'About'
  haml :about
end

#articles

#list of articles
get '/articles' do
  @title = 'List of articles'
  @articles = Article.all(:order => [ :id.desc ], :limit => 20)
  haml :list
end

#form for new article
get '/articles/new' do
  haml :new, :locals => {
    :article => Article.new,
    :action => '/articles/create'
  }
end

#create an article
post '/articles/create' do
  # article = Article.create(:title => params[:title], :body => params[:body])
  article = Article.new
  article.attributes = params['article']
  article.save
  redirect "/articles/#{article.id}"
end

#show an article
get '/articles/:id' do
  # @article = Article.find params[:id]
  @article = Article.get params[:id]
  @comment = Comment.new
  haml :show
end

#form to edit article
get '/articles/:id/edit' do|id|
 article = Article.get(id)
 haml :edit, :locals => {
  :article => article,
  :action => "/articles/#{article.id}/update"
 }
end

# Edit a article
post '/articles/:id/update' do|id|
 article = Article.get(id)
 article.update params[:article]

 redirect "/articles/#{id}"
end

 # Delete a article
post '/articles/:id/destroy' do|id|
 article = Article.get(id)
 article.destroy

 redirect "/articles"
end

#comments

#form for new comment
get '/comments/new' do
  haml :new, :locals => {
    :article => Comment.new,
  }
end

#create an comment
post '/comment/create/:article_id' do
  # article = Comment.create(:body => params[:body], :post_id => params[:article_id])
  article = Article.get(params[:article_id])

  comment = Comment.new
  comment.attributes = params[:comment]
  comment.article = article
  comment.save
  redirect "/articles/#{article.id}"
end

  not_found do
    halt 404, 'page not found'
  end

=begin
  comments
=end