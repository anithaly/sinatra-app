class SinatraApp < Sinatra::Base
  #list of categories
  get '/admin/categories' do
    check_authentication
    @title = 'List of categories'
    @categories = Category.all(:order => [ :id.desc ])
    haml :'categories/list'
  end

  #form for new category
  get '/admin/categories/new' do
    check_authentication
    @category = Category.new
    haml :'categories/new', :locals => {
      :action => '/admin/categories/create'
    }
  end

  #create an category
  post '/admin/categories/create' do
    check_authentication
    # category = Category.create(:title => params[:title], :body => params[:body])
    @category = Category.new
    @category.attributes = params['category']
    if @category.valid?
      @category.save
      redirect "/admin/categories/#{@category.id}"
    else
      haml :'categories/new', :locals => {
        :action => '/admin/categories/create'
      }
    end
  end

  #show an category
  get '/admin/categories/:id' do
    check_authentication
    @category = Category.get params[:id]
    @comment = Comment.new
    haml :'categories/show'
  end

  #form to edit category
  get '/admin/categories/:id/edit' do |id|
    check_authentication
    @category = Category.get(id)
    haml :'categories/edit', :locals => {
      :action => "/admin/categories/#{@category.id}/update"
    }
  end

  # Edit a category
  post '/admin/categories/:id/update' do |id|
    check_authentication
    @category = Category.get(id)

    if @category.update params[:category]
     redirect "/admin/categories/#{id}"
    else
      haml :'categories/edit', :locals => {
        :action => '/admin/categories/#{@category}/edit'
      }
    end
  end

  # Delete a category
  post '/admin/categories/:id/destroy' do |id|
    check_authentication
    category = Category.get(id)
    category.destroy

    content_type :json
    { :id => id }.to_json
    # redirect "/admin/categories"
  end
end