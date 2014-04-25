class SinatraApp < Sinatra::Base

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
      :action => "/comments/create/#{@article.id}"
    }
  end

end