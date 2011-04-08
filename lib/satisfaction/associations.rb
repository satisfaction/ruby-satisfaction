module Associations
  
  def has_many(resource, options={})
    class_name = options[:class_name] || "Sfn::#{resource.to_s.classify}"

    class_eval do
      define_method resource do
        instance_variable_get("@#{resource}") || 
          instance_variable_set("@#{resource}", Sfn::ResourceCollection.new(class_name.constantize, self.satisfaction, options[:url]))
      end
    end   
  end
  
  def belongs_to(resource, options={})
    class_name = options[:class_name] || "Sfn::#{resource.to_s.classify}"
    parent_id = options[:parent_attribute] || "#{resource}_id"
    
    class_eval do
      define_method resource do
        instance_variable_get("@#{resource}") ||
          instance_variable_set("@#{resource}", class_name.constantize.new(parent_id, self.satisfaction))
      end
    end  
  end
end
