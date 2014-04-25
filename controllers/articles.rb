class SinatraApp < Sinatra::Base
# class MyApp < Sinatra::Application

  #list of articles
  get '/admin/articles' do
    check_authentication
    @title = 'List of articles'
    @articles = Article.all(:order => [ :id.desc ])
    haml :'articles/list'
  end

  #form for new article
  get '/admin/articles/new' do
    check_authentication
    @article = Article.new
    haml :'articles/new', :locals => {
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
      haml :'articles/new', :locals => {
        :action => '/admin/articles/create'
      }
    end
  end

  #show an article
  get '/admin/articles/:id' do
    check_authentication
    @article = Article.get params[:id]
    @comment = Comment.new
    haml :'articles/show'
  end

  #form to edit article
  get '/admin/articles/:id/edit' do |id|
    check_authentication
    @article = Article.get(id)
    haml :'articles/edit', :locals => {
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
      haml :'articles/edit', :locals => {
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
end