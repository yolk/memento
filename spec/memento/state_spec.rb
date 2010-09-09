require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::State do
  
  before do
    setup_db
    setup_data
    @session = Memento::Session.create(:user => @user)
  end
  
  it "should belong to session" do
    Memento::State.new(:session => @session).session.should eql(@session)
  end
  
  it "should require session" do
    Memento::State.create.errors[:session].should eql(["can't be blank"])
  end
  
  it "should require action_type to be one of Memento::State::RECORD_CAUSES" do
    Memento::State.create.errors[:action_type].should eql(["can't be blank"])
    Memento::State.create(:action_type => "move").errors[:action_type].should eql(["is not included in the list"])
  end
  
  it "should belong to polymorphic record" do
    Memento::State.new(:record => @user).record.should eql(@user)
    Memento::State.new(:record => @session).record.should eql(@session)
  end
  
  it "should require record" do
    Memento::State.create.errors[:record].should eql(["can't be blank"])
  end
  
  
  describe "valid State" do
    before do
      @state = @session.states.create!(:action_type => "destroy", :record => @project = Project.create(:name => "A") )
    end
    
    it "should give back Memento::Result on undo" do
      result = @state.undo
      result.should be_a(Memento::Result)
      result.object.should be_a(Project)
      result.state.should eql(@state)
    end
    
    it "should give back old data on record_data" do
      @state.record_data.should == (@project.attributes_for_memento)
    end
  end
  
  after do
    shutdown_db
  end
  
end