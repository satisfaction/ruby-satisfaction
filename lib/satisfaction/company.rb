class Sfn::Company < Sfn::Resource
  
  attributes :domain, :name, :logo, :description
  
  def setup_associations
    has_many :people, :url => "#{path}/people"
    has_many :topics, :url => "#{path}/topics"
    has_many :products, :url => "#{path}/products"
    has_many :employees, :url => "#{path}/employees", :class_name => 'Sfn::Person'
    has_many :tags, :url => "#{path}/tags"
    
  end
  
end
