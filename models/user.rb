class User
  include DataMapper::Resource
  include BCrypt

  # hooks
  before :save, :generate_token
  before :create, :generate_token

  # properties
  property :id, Serial, :key => true
  property :name, String, :length => 3..50
  property :email, String, :length => 8..50
  property :password, BCryptHash
  property :token, String, length: 0..100
  property :created_at, DateTime

  # methods
  def generate_token
    # generate token
    self.token = BCrypt::Engine.generate_salt if self.token.nil?
  end

  def authenticate(pass)
    self.password == pass
  end
end