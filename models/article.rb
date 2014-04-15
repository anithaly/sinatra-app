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