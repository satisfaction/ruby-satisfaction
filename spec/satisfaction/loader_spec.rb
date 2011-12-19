require File.dirname(__FILE__) + '/../spec_helper'

describe Sfn::Loader do

  # ==== GET ==========================================================================================================
  shared_examples_for "#get" do
    before(:each) do
      @response = nil
      @status_code = '200'
      @loader = Sfn::Loader.new
      @get = lambda do
        FakeWeb.register_uri(
          :get,
          "http://#{@api_host}:#{@api_port}",
          :body => @response_body,
          :status => [@status_code]
        )
        stub(@loader).add_authentication {}
        @response = @loader.get(@api_url)
      end
    end

    describe "when the status is successful (2xx)" do
      before(:each) do
        @status_code.should == '200'
        @response_body = {:id => "123", :domain => "foo.bar"}.to_json
        @get.call
      end

      it "should return a status of :ok and the response body" do
        @response.should == [:ok, @response_body]
      end
    end

    describe "when the status is not modified (304)" do
      before(:each) do
        @status_code = '304'
        @cached_body = {:id => "123", :domain => "foo.bar"}.to_json
        @response_body = nil
        stub(@loader.cache).get(anything) { Sfn::Loader::CacheRecord.new('http://test', 'etag-foo', @cached_body) }

        @get.call
      end

      it "should return a status of :ok and the cached response body" do
        @response.should == [:ok, @cached_body]
      end
    end

    describe "when the status is 400 (Bad Request)" do
      before(:each) do
        @status_code = '400'
        @response_body = {:message => "You've already me-too'd this topic."}.to_json
      end

      it "should return a status of :bad_request and the response body" do
        @get.should raise_error(Sfn::BadRequest, "Bad request. Response body:\n" + @response_body)
      end
    end

    describe "when there is an authentication error" do
      describe "when the status is 401 (Unauthorized)" do
        before(:each) do
          @status_code = '401'
        end

        it "should raise an Sfn::AuthorizationError" do
          @get.should raise_error(Sfn::AuthorizationError, "Not authorized")
        end
      end

      describe "when the status is 403 (Forbidden)" do
        before(:each) do
          @status_code = '403'
        end
        
        it "should raise an Sfn::AuthorizationError" do
          @get.should raise_error(Sfn::AuthorizationError, "Not authorized")
        end
      end
    end

  # ---- MAINTENANCE --------------------------------------------------------------------------------------------------
    describe "when the status is 404 (Not Found)" do
      before(:each) do
        @status_code = '404'
      end

      it "should raise an Sfn::NotFound error" do
        @get.should raise_error(Sfn::NotFound, "Not found")
      end
    end

    describe "when the site is in maintenance mode (503)" do
      before(:each) do
        @status_code = '503'
        @response_body = "blah blah maintenance blah"
      end

      describe "and there is not an element with a class of error_message_summary in the HTML" do
        it "should raise an error and include the default maintenance message" do
          @get.should raise_error(Sfn::SiteMaintenance, "The site is down for maintenance. Please try again later.")
        end
      end

      describe "and there is an element with a class of error_message_summary in the HTML" do
        before(:each) do
          @custom_error = "Something crazy is going down!"
          @response_body = "<html><head></head><body><h2 class='error_message_summary'>#{@custom_error}</h2></body>"
        end

        it "should raise an error and include the contents of the element" do
          @get.should raise_error(Sfn::SiteMaintenance, @custom_error)
        end
      end
    end

    describe "when the error is not one we explicitly check for" do
      before(:each) do
        @status_code = '505' # HTTP Version Not Supported
        @response_body = "it'd be a little weird if our app responded with this error"
      end

      it "should raise an Sfn::Error and include the response body" do
        begin
          @get.call
        rescue Sfn::Error => e
          e.class.should == Sfn::Error
          e.message.should == "Encountered error. Body of response:\n" + @response_body
        end
      end
    end

  # ---- GATEWAY -----------------------------------------------------------------------------------------------
    describe "when the status is 502 (Bad Gateway, returned when a Unicorn worker is killed)" do
      before(:each) do
        @status_code = '502'
      end

      it "should raise an Sfn::BadGateway error" do
        @get.should raise_error(Sfn::BadGateway, "Bad Gateway")
      end
    end

    describe "when the status is 504 (GatewayTimeOut)" do
      before(:each) do
        @status_code = '504'
      end

      it "should raise an Sfn::GatewayTimeOut error" do
        @get.should raise_error(Sfn::GatewayTimeOut, "Gateway TimeOut")
      end
    end
  end

  # ==== POST ==================================================================================================
  shared_examples_for "#post" do
    before(:each) do
      @response = nil
      @status_code = '200'
      @post = lambda do
        FakeWeb.register_uri(
          :post,
          "http://#{@api_host}:#{@api_port}",
          :body => @response_body,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.post(@api_url, "a=b")
      end
    end

    describe "when the status is successful (2xx)" do
      before(:each) do
        @status_code.should == '200'
        @response_body = {:id => "123", :domain => "foo.bar"}.to_json
        @post.call
      end

      it "should return a status of :ok and the response body" do
        @response.should == [:ok, @response_body]
      end
    end

    describe "when the status is 400 (bad request)" do
      before(:each) do
        @status_code = '400'
        @response_body = 'some error message'.to_json
      end

      it "should return raise an Sfn::BadRequest error and the response body" do
        @post.should raise_error(Sfn::BadRequest, "Bad request. Response body:\n" + @response_body)
      end
    end

    describe "when there is an authentication error" do
      describe "when the status is 401 (Unauthorized)" do
        before(:each) do
          @status_code = '401'
        end

        it "should raise an Sfn::AuthorizationError" do
          @post.should raise_error(Sfn::AuthorizationError, "Not authorized")
        end
      end

      describe "when the status is 403 (Forbidden)" do
        before(:each) do
          @status_code = '403'
        end
        
        it "should raise an Sfn::AuthorizationError" do
          @post.should raise_error(Sfn::AuthorizationError, "Not authorized")
        end
      end
    end

    describe "when the status is 404 (Not Found)" do
      before(:each) do
        @status_code = '404'
      end

      it "should raise an Sfn::NotFound error" do
        @post.should raise_error(Sfn::NotFound, "Not found")
      end
    end

  # ---- GATEWAY -----------------------------------------------------------------------------------------------
    describe "when the status is 502 (Bad Gateway, returned when a Unicorn worker is killed)" do
      before(:each) do
        @status_code = '502'
      end

      it "should raise an Sfn::BadGateway error" do
        @post.should raise_error(Sfn::BadGateway, "Bad Gateway")
      end
    end

    describe "when the status is 504 (GatewayTimeOut)" do
      before(:each) do
        @status_code = '504'
      end

      it "should raise an Sfn::GatewayTimeOut error" do
        @post.should raise_error(Sfn::GatewayTimeOut, "Gateway TimeOut")
      end
    end
  end

  context 'over ssl' do
    before do
      @api_host = 'test'
      @api_url  = "https://#{@api_host}"
      @api_port = "443" 
      any_instance_of(Net::HTTP) do |n|
        mock(n).use_ssl=(true)
      end
    end

    it_should_behave_like '#get'
    it_should_behave_like '#post'
  end

  context 'not over ssl' do
    before do
      @api_host = 'test'
      @api_url  = "http://#{@api_host}"
      @api_port = ""
    end

    it_should_behave_like '#get'
    it_should_behave_like '#post'

    
    describe "when we are in a redirect loop" do
      attr_reader :loader

      before(:each) do
        @url = @api_url
        @loader = Sfn::Loader.new
        stub(loader).add_authentication {}
      end

      describe "and the status is 301" do
        before(:each) do
          @get = lambda { 
            FakeWeb.register_uri(:get, "http://#{@api_host}:#{@api_port}", :status => 301, :location => @url)
            @response = loader.get(@url)
          }
        end

        it "should raise a TooManyRedirects exception with an appropriate message" do
          @get.should raise_error(Sfn::TooManyRedirects, "Too many redirects")
        end
      end

      describe "and the status is 302" do
        before(:each) do
          @get = lambda { 
            FakeWeb.register_uri(:get, "http://#{@api_host}:#{@api_port}", :status => 302, :location => @url)
            @response = loader.get(@url)
          }
        end

        it "should raise a TooManyRedirects exception with an appropriate message" do
          @get.should raise_error(Sfn::TooManyRedirects, "Too many redirects")
        end
      end
    end
  end

  # ---- MAINTENANCE --------------------------------------------------------------------------------------------------
  describe 'MAINTENANCE' do
    before(:each) do
      @api_url = "http://test"
      @response = nil
      @status_code = '200'
      @post = lambda do
        FakeWeb.register_uri(
          :post,
          @api_url,
          :body => @response_body,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.post(@api_url, "a=b")
      end
    end

    shared_examples_for "the site is in maintenance mode" do
      describe "and there is not an element with a class of error_message_summary in the HTML" do
        before(:each) do
          FakeWeb.register_uri(:get, @api_url, :body => "blah", :status => "503")
        end

        it "should raise an error and include the default maintenance message" do
          @post.should raise_error(Sfn::SiteMaintenance, "The site is down for maintenance. Please try again later.")
        end
      end

      describe "and there is an element with a class of error_message_summary in the HTML" do
        before(:each) do
          @custom_error = "Something crazy is going down!"
            @response_body = "<html><head></head><body><h2 class='error_message_summary'>#{@custom_error}</h2></body>"
            FakeWeb.register_uri(:get, @api_url, :body => @response_body, :status => "503")
          end

        it "should raise an error and include the contents of the element" do
          @post.should raise_error(Sfn::SiteMaintenance, @custom_error)
        end
      end
    end

    describe "when the status is 405 (Method Not Allowed)" do
      before(:each) do
        @status_code = '405'
        @response_body = "blah blah maintenance blah"
      end

      it_should_behave_like "the site is in maintenance mode"

      describe "when the site is not in maintenance mode" do
        before(:each) do
          FakeWeb.register_uri(:get, @api_url, :body => "blah", :status => "200")
        end

        it "should raise an error and include the reponse body" do
          @post.should raise_error(Sfn::MethodNotAllowed, "Method not allowed")
        end
      end
    end

    describe "when the status is 503 (Service Unavailable)" do
      before :each do
        @status_code = '503'
        @response_body = "blah blah maintenance mode"
      end

      it_should_behave_like "the site is in maintenance mode"
    end


    describe "when the error is not one we explicitly check for" do
      before(:each) do
        @status_code = '505' # HTTP Version Not Supported
        @response_body = "it'd be a little weird if our app responded with this error"
      end

      it "should raise an Sfn::Error and include the response body" do
        begin
          @post.call
        rescue Sfn::Error => e
          e.class.should == Sfn::Error
          e.message.should == "Encountered error. Body of response:\n" + @response_body
        end
      end
    end
  end
end
