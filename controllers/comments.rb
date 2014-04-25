class SinatraApp < Sinatra::Base
  #comments

  #create an comment
  post '/comments/create/:article_id' do
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
        :action => "/comments/create/#{@article.id}"
      }
    end
  end
end