require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::Result do
  
  describe "when initalized with valid object" do
    before do
      @object = mock("object", :errors => {})
      @state = mock("state1")
      @result = Memento::Result.new(@object, @state)
    end

    it "should have an object attribute" do
      @result.object.should eql(@object)
    end
    
    it "should have an state attribute" do
      @result.state.should eql(@state)
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
      @object = mock("object", :errors => {:memento_undo => "123"})
      @result = Memento::Result.new(@object, mock("state1"))
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

describe Memento::ResultArray do
  
  before do
    @results = Memento::ResultArray.new()
  end
  
  it "should have an empty errors array" do
    @results.errors.should eql([])
  end
  
  it "should have no errors" do
    @results.should be_success
    @results.should_not be_failed
  end
  
  describe "when Memento::Result without errors added" do
    before do
      @object = mock("object", :errors => {:memento_undo => "123"})
      @results << Memento::Result.new(mock("object2", :errors => {}), mock("state1"))
      @results << (@with_error = Memento::Result.new(@object, mock("state2")))
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