require 'spec_helper'

describe 'Smoke test SSL conections' do
  before do
    @app_host = 'getsatisfaction.com'
    @api_host = 'api.getsatisfaction.com'
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  shared_examples_for 'get' do
    it 'should get the first page of getsat topics' do
      results = @sfn.companies['getsatisfaction'].topics.page(1, :limit => 10)
      results.items.size.should == 10
    end
  end

  context 'over ssl' do
    before do
      @sfn = Satisfaction.new(
        :root => "https://#{@api_host}",
        :autoload => false,
        :request_token_url => "https://#{@app_host}/api/request_token",
        :access_token_url => "https://#{@app_host}/api/access_token",
        :authorize_url => "https://#{@app_host}/api/authorize"
      )
    end

    it_should_behave_like 'get'  
  end

  context 'not over ssl' do
    before do
      @sfn = Satisfaction.new(
        :root => "http://#{@api_host}",
        :autoload => false,
        :request_token_url => "http://#{@app_host}/api/request_token",
        :access_token_url => "http://#{@app_host}/api/access_token",
        :authorize_url => "http://#{@app_host}/api/authorize"
      )
    end

    it_should_behave_like 'get'
  end
end
