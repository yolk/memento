class Memento::ResultArray < Array
  
  def errors
    self.find_all{ |result| result.failed? }
  end
  
  def failed?
    self.any?{ |result| result.failed? }
  end
  
  def success?
    !failed?
  end
  
end

class Memento::Result
  
  attr_reader :object, :state
  
  def initialize(object, state)
    @object, @state = object, state
  end
  
  def error
    @object.errors[:memento_undoing]
  end
  
  def failed?
    !!error
  end
  
  def success?
    !failed?
  end
end