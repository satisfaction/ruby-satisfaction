require 'spec_helper'

describe Satisfaction do

  describe "#request_token" do

    describe "when the http response is 200 OK" do
      before :each do
        @sfn.set_consumer('key', 'secret')

        FakeWeb.register_uri(
          :get,
          "http://#{@app_host}/api/request_token",
          :body => "oauth_token=foo&oauth_token_secret=bar",
          :status => ['200']
        )
      end

      it "should be successful" do
        oauth = @sfn.request_token
        oauth.token.first.should == "foo"
        oauth.secret.first.should == "bar"
      end
    end

    describe "when the http response is 503 Service Temporarily Unavailable" do
      before(:each) do
        FakeWeb.register_uri(
          :get, 
          "http://#{@app_host}/api/request_token",
          :body => "<html><head><title>maintenance</title><head><body>maintenance</body></html>",
          :status => ['503']
        )
      end

      it "should raise an exception" do
        lambda {@sfn.request_token}.should raise_exception(Sfn::Error)
      end
    end
  end

end
