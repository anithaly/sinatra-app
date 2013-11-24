require 'sinatra'

set :haml, :format => :html5, :layout_engine => :haml, :layout => :layout

get '/' do
  @title = 'Welcome!'
  haml :home, :locals => {:title => @title}
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params[:name] is 'foo' or 'bar'
  @title = @hello = "Hello #{params[:name]}!"
  haml :hello, :locals => {:title => @title, :hello => @hello}
end

get '/about' do
  @title = 'About'
  haml :about, :locals => {:title => @title}
end

get '/articles' do
  @title = 'List of articles'
  haml :index, :locals => {:title => @title}
end

get '/articles/create' do
  etag '', :new_resource => true
  Article.create
  erb :new_article
end

get '/article/:id' do
  @article = Article.find params[:id]
  last_modified @article.updated_at
  etag @article.sha1
  erb :article
end

=begin
delete '/' do
  #.. annihilate something ..
end
=end