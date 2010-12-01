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
          :body => @response_body.to_json,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.get('http://test')
      end
    end

    describe "when the status is 200" do
      before(:each) do
        @status_code.should == '200'
        @response_body = {:id => "123", :domain => "foo.bar"}
        @get.call
      end

      it "should return a status of :ok and the response body" do
        @response.should == [:ok, @response_body.to_json]
      end
    end

    describe "when the status is 400" do
      before(:each) do
        @status_code = '400'
        @response_body = {:message => "You've already me-too'd this topic."}
      end

      it "should return a status of :bad_request and the response body" do
        @get.should raise_error(RuntimeError, @response_body.to_json)
      end
    end

    describe "when the status is 503" do
      before(:each) do
        @status_code = '503'
        @response_body = "blah blah maintenance blah"
      end

      it "should raise an error and include the maintenance message" do
        @get.should raise_error(RuntimeError, "The site is down for maintenance. Please try again later.")
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
          :body => @response_body.to_json,
          :status => [@status_code]
        )
        loader = Sfn::Loader.new
        stub(loader).add_authentication {}
        @response = loader.post('http://test', "a=b")
      end
    end

    describe "when the status is 200" do
      before(:each) do
        @status_code.should == '200'
        @response_body = {:id => "123", :domain => "foo.bar"}
        @post.call
      end

      it "should return a status of :ok and the response body" do
        @response.should == [:ok, @response_body.to_json]
      end
    end

    describe "when the status is 400" do
      before(:each) do
        @status_code = '400'
        @response_body = 'some error message'
      end

      it "should return a status of :bad_request and the response body" do
        @post.should raise_error(RuntimeError, @response_body.to_json)
      end
    end

    describe "when the status is 405" do
        before(:each) do
          @status_code = '405'
          @response_body = "blah blah maintenance blah"
        end

      describe "and when the site is in maintenance mode" do
        before(:each) do
          FakeWeb.register_uri(:get, 'http://test', :body => "blah", :status => "503")
        end

        it "should raise an error and include the maintenance message" do
          @post.should raise_error(RuntimeError, "The site is down for maintenance. Please try again later.")
        end
      end

      describe "and the site is not in maintenance mode" do
        before(:each) do
          FakeWeb.register_uri(:get, 'http://test', :body => "blah", :status => "200")
          @post.call
        end

        it "should raise an error and include the reponse body" do
          @response.should == [ :method_not_allowed, @response_body.to_json ]
        end

      end
    end

  end

end
