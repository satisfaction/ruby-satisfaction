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
        @get.call
      end

      it "should return a status of :bad_request and the response body" do
        @response.should == [:bad_request, @response_body.to_json]
      end

    end
  end
end
