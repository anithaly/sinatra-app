class Comment
  include DataMapper::Resource
  property :id, Serial
  property :body, Text, :required => true
  property :created_at, DateTime
  # belongs_to :user
  belongs_to :article
end