require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::Session do
  
  before do
    setup_db
    setup_data
    @session = Memento::Session.create(:user => @user)
  end
  
  it "should belong to user" do
    @session.user.should eql(@user)
  end
  
  it "should require user" do
    Memento::Session.create.errors[:user].should eql(["can't be blank"])
  end
  
  it "should have_many states" do
    @session.states.should eql([])
    @session.states.create!(:action_type => "destroy", :record => Project.create!)
    @session.states.count.should eql(1)
  end
  
  context "undo" do
    before do
      @state1 = @session.states.create!(:action_type => "update", :record => @p1 = Project.create!)
      @other = Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => Project.create!)
      @state2 = @session.states.create!(:action_type => "update", :record => @p2 = Project.create!)
    end
    
    describe "and all states succeed" do
      it "should return ResultsArray" do
        @session.undo.should be_a(Memento::ResultArray)
      end
      
      it "should remove all states" do
        @session.undo
        Memento::State.count.should eql(1)
      end
      
      it "should remove itself" do
        @session.undo
        Memento::Session.find_by_id(@session.id).should be_nil
      end
    end
    
    describe "and all states fail" do
      before do
        @state1.update_attribute(:record_data, {:name => ["A", "B"]})
        @p1.update_attribute(:name, "C")
        @state2.update_attribute(:record_data, {:name => ["A", "B"]})
        @p2.update_attribute(:name, "C")
      end
      
      it "should keep all states" do
        @session.undo
        Memento::State.count.should eql(3)
      end
      
      it "should keep itself" do
        @session.undo
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind on undo!" do
        lambda{ @session.undo! }.should raise_error(Memento::ErrorOnRewind)
      end
    end
    
    describe "and some states succeed, some fail" do
      before do
        @state1.update_attribute(:record_data, {:name => ["A", "B"]})
        @p1.update_attribute(:name, "C")
      end

      it "should keep all states when using undo!" do
        @session.undo! rescue
        Memento::State.count.should eql(3)
      end
      
      it "should NOT keep all states when using undo" do
        @session.undo
        Memento::State.count.should eql(2)
      end

      it "should keep itself" do
        @session.undo rescue nil
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind on undo!" do
        lambda{ @session.undo! }.should raise_error(Memento::ErrorOnRewind)
      end
    end
  
    it "should undo states in order of creation (newest first)" do
      @session.undo.map(&:state).map(&:id).should eql([@state2.id, @state1.id])
    end
  end
  
  describe "with states" do
    before do
      @session.states.create!(:action_type => "destroy", :record => Project.create!)
      Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => Project.create!)
      @state2 = @session.states.create!(:action_type => "update", :record => Project.create!)
    end
    
    it "should destroy all states when destroyed" do
      Memento::State.count.should eql(3)
      @session.destroy
      Memento::State.count.should eql(1)
    end
    
  end
  
  after do
    shutdown_db
  end
  
end