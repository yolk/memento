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
  
  attr_reader :object, :track
  
  def initialize(object, track)
    @object, @track = object, track
  end
  
  def error
    @object.errors[:memento_rewind]
  end
  
  def failed?
    !!error
  end
  
  def success?
    !failed?
  end
end