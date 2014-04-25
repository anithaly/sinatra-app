# encoding: utf-8
SITE_TITLE = "Sinatra app"

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

# Load up all models next
Dir[File.dirname(__FILE__) + "/models/*.rb"].each do |file|
  require file
end

DataMapper.finalize
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!

Dir[File.dirname(__FILE__) + "/controllers/*.rb"].each do |file|
  require file
end

# require_relative 'controllers/articles'

if User.count == 0
  @user = User.create(email: "admin@it.works")
  @user.password = "admin"
  @user.save
end

class SinatraApp < Sinatra::Base

  # general configs
  configure do
    set :root          , File.dirname(__FILE__)
    set :public_folder , File.dirname(__FILE__) + '/public'
    set :app_file      , __FILE__
    set :views         , File.dirname(__FILE__) + '/views'
    set :haml          , :format => :html5
    # set :tests         , File.dirname(__FILE__) + '/tests'
    # set :dump_errors   , true
    # set :logging       , true
    # set :raise_errors  , true
    # enable :sessions
    use Rack::Session::Cookie, secret: "nothingissecretontheinternet"
    use Rack::Flash, accessorize: [:error, :success] #:,sweep => true,
    register Sinatra::Partial
  end

  configure :development do
    register Sinatra::Reloader
    enable :reloader
  end

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:hashed_password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:hashed_password) do
    # flash is not reached
    # we create a wrap
    def flash
      env['x-rack.flash']
    end

    def valid?
      params['email'] && params['password']
    end

    # authenticating user
      def authenticate!
        # find for user
        user = User.first(email: params['email'])
        if user.nil?
          fail!("Invalid email, doesn't exists!")
          flash.error = ""
        elsif user.authenticate(params['password'])
          flash.success = "Logged in"
          success!(user)
        else
          fail!("There are errors, please try again")
        end
      end
  end

  helpers do
    # include Rack::Utils
    # alias_method :h, :escape_html

    def warden_handler
      env['warden']
    end

    def current_user
      warden_handler.user
    end

    def check_authentication
      redirect '/login' unless warden_handler.authenticated?
    end
  end

end