require 'rubygems'
require 'rspec'
require 'fakeweb'
require 'ruby-debug'
require 'rr'
require 'erector'

Debugger.settings[:autolist] = 1
Debugger.settings[:autoeval] = true
Debugger.start

$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'satisfaction'

RSpec.configure do |config|

  config.mock_with(:rr)

  config.before(:each) do
    @app_host = 'app.gsfn:3000'
    @api_host = 'api.gsfn:3001'
    @sfn = Satisfaction.new(
      :root => "http://#{@api_host}",
      :autoload => false,
      :request_token_url => "http://#{@app_host}/api/request_token",
      :access_token_url => "http://#{@app_host}/api/access_token",
      :authorize_url => "http://#{@app_host}/api/authorize"
    )
    FakeWeb.allow_net_connect = false
  end

  config.after(:each) do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

end
