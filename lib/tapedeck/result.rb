class Tapedeck::ResultArray < Array
  
  def errors
    self.find_all{ |result| result.failed? }
  end
  
  def failed?
    self.any?{ |result| result.failed? }
  end
  
  def successful?
    !failed?
  end
  
end

class Tapedeck::Result
  
  attr_reader :object
  
  def initialize(object)
    @object = object
  end
  
  def error
    @object.errors[:tapedeck_rewind]
  end
  
  def failed?
    !!error
  end
  
  def successful?
    !failed?
  end
end