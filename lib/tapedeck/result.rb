class Tapedeck::ResultArray < Array
  
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

class Tapedeck::Result
  
  attr_reader :object, :track
  
  def initialize(object, track)
    @object, @track = object, track
  end
  
  def error
    @object.errors[:tapedeck_rewind]
  end
  
  def failed?
    !!error
  end
  
  def success?
    !failed?
  end
end