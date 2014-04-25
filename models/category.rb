class Category
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 3..50
  property :created_at, DateTime
  has n, :articles
  # belongs_to :user
end