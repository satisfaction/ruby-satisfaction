require File.dirname(__FILE__) + '/../spec_helper'

describe "Identity Map" do
  before(:each) do
    gsfn = {:id => 4, :domain => 'getsatisfaction'}

    # Single record response w/ gsfn
    FakeWeb.register_uri(
      :get,
      "http://#{@api_host}/companies/4.json",
      :body => gsfn.to_json
    )

    # Collection response that includes gsfn
    FakeWeb.register_uri(
      :get,
      "http://#{@api_host}/companies.json?q=satisfaction&page=1&limit=10",
      :body => {"total" => 1, "data" => [gsfn]}.to_json
    )
  end

  it "should work single instances" do
    c1 = @sfn.companies.get(4)
    c2 = @sfn.companies.get(4)
    
    c1.object_id.should == c2.object_id
  end
  
  it "should load one if the other gets loaded" do
    c1 = @sfn.companies.get(4)
    c2 = @sfn.companies.get(4)
    c2.should_not be_loaded
    
    c1.load
  
    c2.should be_loaded
    c2.domain.should == 'getsatisfaction'
  end
  
  it "should work with pages too" do
    c1 = @sfn.companies.get(4)
    c2 = @sfn.companies.page(1, :q => 'satisfaction').first
    
    c1.object_id.should == c2.object_id
  end
end
