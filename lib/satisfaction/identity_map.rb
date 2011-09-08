class Sfn::IdentityMap
  attr_reader :records, :pages
  
  def initialize
    @records = {}
    @pages = {}
  end
  
  def get_record(klass, id, path='', &block)
    result = @records[[klass, id, path]]
    result ||= begin
      obj = yield(klass, id, path)
      @records[[klass, id, path]] = obj
    end
    result
  end
  
  def expire_record(klass, id, path='')
    @records[[klass, id, path]] = nil
  end
end
