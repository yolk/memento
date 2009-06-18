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
    Memento::State.create.errors[:session].should eql("can't be blank")
  end
  
  it "should require action_type to be one of Memento::State::RECORD_CAUSES" do
    Memento::State.create.errors[:action_type].should eql("can't be blank")
    Memento::State.create(:action_type => "move").errors[:action_type].should eql("is not included in the list")
  end
  
  it "should belong to polymorphic record" do
    Memento::State.new(:record => @user).record.should eql(@user)
    Memento::State.new(:record => @session).record.should eql(@session)
  end
  
  it "should require record" do
    Memento::State.create.errors[:record].should eql("can't be blank")
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
    
    it "should give back new unsaved copy of object on new_object" do
      @state.new_object.should be_kind_of(Project)
      @state.new_object.name.should be_nil
      @state.new_object do |object|
        object.name = "B"
      end.name.should eql("B")
    end
    
    it "should give back new unsaved copy filled with old data of object on rebuild_object" do
      @state.rebuild_object.should be_kind_of(Project)
      @state.rebuild_object.name.should eql("A")
      @state.rebuild_object(:id).id.should be_nil # skip id
      @state.rebuild_object.id.should eql(@project.id)
      @state.rebuild_object do |object|
        object.name = "B"
      end.name.should eql("B")
    end
    
    describe "on later_states_on_record_for" do
      
      it "should return empty array" do
        @state.later_states_on_record_for("destroy").should eql([])
      end

      it "should return filled array when other record of the given action_type exists" do
        Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => @project )
        @state.later_states_on_record_for("destroy").map(&:class).should eql([Memento::State])
        @state.later_states_on_record_for(:"destroy").map(&:id).should eql([2])
      end
      
      it "should return empty array when only records of another action_type exists" do
        Memento::Session.create!(:user => @user).states.create!(:action_type => "update", :record => @project )
        @state.later_states_on_record_for("destroy").should eql([])
      end
      
      it "should return empty array when only destroy records of another record exists" do
        Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => Project.create(:name => "B") )
        @state.later_states_on_record_for("destroy").should eql([])
      end
      
      it "should return empty array when only destroy records older than @tack exist" do
        state2 = Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => @project )
        state2.update_attribute(:created_at, 3.minutes.ago)
        @state.later_states_on_record_for("destroy").should eql([])
      end
    end
    
    
    
  end
  
  after do
    shutdown_db
  end
  
end