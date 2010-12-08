require File.dirname(__FILE__) + '/../spec_helper'

describe Sfn::Loader do
  describe "#get" do
    before(:each) do
      @response = nil
      @status_code = '200'
      @get = lambda do
        FakeWeb.register_uri(
          :get,
          'http://test',
          :body => @response_body,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.get('http://test')
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

    describe "when we are in a redirect loop" do
      before(:each) do
        @status_code = '301'
        @url = 'http://loop/'
        FakeWeb.register_uri(:get, @url, :status => @status_code, :location => @url)
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @get = lambda { @response = loader.get(@url) }
      end

      it "should raise a TooManyRedirects exception with an appropriate message" do
        @get.should raise_error(Sfn::TooManyRedirects, "Too many redirects")
      end
    end

    describe "when the status is 400 (Bad Request)" do
      before(:each) do
        @status_code = '400'
        @response_body = {:message => "You've already me-too'd this topic."}.to_json
      end

      it "should return a status of :bad_request and the response body" do
        @get.should raise_error(Sfn::BadRequest, @response_body)
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

      it "should raise an Sfn::Error and include the response in yaml format" do
        begin
          @get.call
        rescue Sfn::Error => e
          e.class.should == Sfn::Error
          YAML::load(e.message).body.should == @response_body
        end
      end
    end
  end

  describe "#post" do
    before(:each) do
      @response = nil
      @status_code = '200'
      @post = lambda do
        FakeWeb.register_uri(
          :post,
          'http://test',
          :body => @response_body,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.post('http://test', "a=b")
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
        @post.should raise_error(Sfn::BadRequest, @response_body)
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

    describe "when the status is 405 (Method Not Allowed)" do
        before(:each) do
          @status_code = '405'
          @response_body = "blah blah maintenance blah"
        end

        describe "and when the site is in maintenance mode" do

          describe "and there is not an element with a class of error_message_summary in the HTML" do
            before(:each) do
              FakeWeb.register_uri(:get, 'http://test', :body => "blah", :status => "503")
            end

            it "should raise an error and include the default maintenance message" do
              @post.should raise_error(Sfn::SiteMaintenance, "The site is down for maintenance. Please try again later.")
            end
          end

          describe "and there is an element with a class of error_message_summary in the HTML" do
            before(:each) do
              @custom_error = "Something crazy is going down!"
              @response_body = "<html><head></head><body><h2 class='error_message_summary'>#{@custom_error}</h2></body>"
              FakeWeb.register_uri(:get, 'http://test', :body => @response_body, :status => "503")
            end

            it "should raise an error and include the contents of the element" do
              @post.should raise_error(Sfn::SiteMaintenance, @custom_error)
            end
          end
        end

      describe "and the site is not in maintenance mode" do
        before(:each) do
          FakeWeb.register_uri(:get, 'http://test', :body => "blah", :status => "200")
          @post.call
        end

        it "should raise an error and include the reponse body" do
          @response.should == [ :method_not_allowed, @response_body ]
        end

      end
    end

    describe "when the error is not one we explicitly check for" do
      before(:each) do
        @status_code = '505' # HTTP Version Not Supported
        @response_body = "it'd be a little weird if our app responded with this error"
      end

      it "should raise an Sfn::Error and include the response in yaml format" do
        begin
          @post.call
        rescue Sfn::Error => e
          e.class.should == Sfn::Error
          YAML::load(e.message).body.should == @response_body
        end
      end
    end

  end

end
