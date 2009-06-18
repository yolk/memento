require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tapedeck::Result do
  
  describe "when initalized with valid object" do
    before do
      @object = mock("object", :errors => {})
      @track = mock("track1")
      @result = Tapedeck::Result.new(@object, @track)
    end

    it "should have an object attribute" do
      @result.object.should eql(@object)
    end
    
    it "should have an track attribute" do
      @result.track.should eql(@track)
    end

    it "should have an error attribute" do
      @result.error.should be_nil
    end

    it "should be valid" do
      @result.should be_success
      @result.should_not be_failed
    end
  end
  
  describe "when initalized with object with errors" do
    before do
      @object = mock("object", :errors => {:tapedeck_rewind => "123"})
      @result = Tapedeck::Result.new(@object, mock("track1"))
    end
    
    it "should have an object attribute" do
      @result.object.should eql(@object)
    end

    it "should return error" do
      @result.error.should eql("123")
    end

    it "should be invalid" do
      @result.should be_failed
      @result.should_not be_success
    end
  end

end

describe Tapedeck::ResultArray do
  
  before do
    @results = Tapedeck::ResultArray.new()
  end
  
  it "should have an empty errors array" do
    @results.errors.should eql([])
  end
  
  it "should have no errors" do
    @results.should be_success
    @results.should_not be_failed
  end
  
  describe "when Tapedeck::Result without errors added" do
    before do
      @object = mock("object", :errors => {:tapedeck_rewind => "123"})
      @results << Tapedeck::Result.new(mock("object2", :errors => {}), mock("track1"))
      @results << (@with_error = Tapedeck::Result.new(@object, mock("track2")))
    end
    
    it "should have two entrys" do
      @results.size.should eql(2)
    end
    
    it "should have one error" do
      @results.errors.size.should eql(1)
      @results.errors.should eql([@with_error])
    end
    
    it "should have an error" do
      @results.should_not be_success
      @results.should be_failed
    end
  end
  
end