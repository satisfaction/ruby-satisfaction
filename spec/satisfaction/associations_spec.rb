require File.dirname(__FILE__) + '/../spec_helper'

describe "Associations" do
  describe "when included in a class" do
    attr_reader :klass, :obj

    before(:each) do
      @klass = Class.new
      @klass.class_eval do
        include Associations
      end
      @obj = @klass.new
    end

    describe "#has_many" do
      before(:each) do
        klass.instance_methods.should_not include("topics")
        Associations.instance_methods.should_not include("topics")
        obj.methods.should_not include("topics")
        obj.has_many :topics, :url => "/path/topics"
      end

      it "should create a method on the object the method is invoked on" do
        obj.methods.should include("topics")
      end

      it "should not create an instance method on the including class" do
        klass.instance_methods.should_not include("topics")
      end

      it "should not create an instance method on Associations" do
        Associations.instance_methods.should_not include("topics")
      end

    end

    describe "#belongs_to" do
      before(:each) do
        klass.instance_methods.should_not include("company")
        Associations.instance_methods.should_not include("company")
        obj.methods.should_not include("company")
        obj.belongs_to :company, :url => "/path/company"
      end

      it "should create a method on the object the method is invoked on" do
        obj.methods.should include("company")
      end

      it "should create an instance method on the including class" do
        klass.instance_methods.should_not include("company")
      end

      it "should not create an instance method on Associations" do
        Associations.instance_methods.should_not include("company")
      end
    end
  end
end
