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
    Memento::Session.create.errors[:user].should eql("can't be blank")
  end
  
  it "should have_many states" do
    @session.states.should eql([])
    @session.states.create!(:action_type => "destroy", :record => Project.create!)
    @session.states.count.should eql(1)
  end
  
  describe "on undo" do
    before do
      @states = [@t1 = mock("t1"), @t2 = mock("t2")]
      @session.stub!(:states).and_return(@states)
    end
    
    describe "and all states fail" do
      before do
        @t1.stub!(:undo).once().and_return(mock("r1", :success? => false))
        @t2.stub!(:undo).once().and_return(mock("r2", :success? => false))
        @states.stub!(:count).and_return(2)
      end
      
      it "should call undo on all states when undo is called" do
        @t1.should_receive(:undo).once().and_return(mock("r1", :success? => false))
        @t2.should_receive(:undo).once().and_return(mock("r2", :success? => false))
        @session.undo
      end
      
      it "should kepp itself" do
        @session.undo
        @session.reload
      end
    end
    
    describe "and all states succeed" do
      before do
        @t1.stub!(:undo).once().and_return(mock("r1", :success? => true, :state => @t1))
        @t2.stub!(:undo).once().and_return(mock("r2", :success? => true, :state => @t2))
        @t1.stub!(:destroy).once()
        @t2.stub!(:destroy).once()
        @states.stub!(:count).and_return(0)
      end
      
      it "should destroy itself" do
        @session.undo
        Memento::Session.find_by_id(@session.id).should be_nil
      end
      
      it "should destroy all states" do
        @t1.should_receive(:destroy).once()
        @t2.should_receive(:destroy).once()
        @session.undo
      end
    end
    
    describe "and some states succeed, some fail" do
      before do
        @t1.stub!(:undo).once().and_return(mock("r1", :success? => true, :state => @t1))
        @t2.stub!(:undo).once().and_return(mock("r2", :success? => false, :state => @t2))
        @t1.stub!(:destroy).once()
        @states.stub!(:count).and_return(1)
      end
      
      it "should kepp itself" do
        @session.undo
        @session.reload
      end
      
      it "should destroy only successful states" do
        @t1.should_receive(:destroy).once()
        @t2.should_receive(:destroy).never()
        @session.undo
      end
    end
  end
  
  describe "on undo!" do
    before do
      @state1 = @session.states.create!(:action_type => "update", :record => @p1 = Project.create!)
      Memento::Session.create!(:user => @user).states.create!(:action_type => "destroy", :record => Project.create!)
      @state2 = @session.states.create!(:action_type => "update", :record => @p2 = Project.create!)
    end
    
    describe "and all states succeed" do
      it "should return ResultsArray" do
        @session.undo!.should be_a(Memento::ResultArray)
      end
      
      it "should remove all states" do
        @session.undo!
        Memento::State.count.should eql(1)
      end
      
      it "should remove itself" do
        @session.undo!
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
        @session.undo! rescue
        Memento::State.count.should eql(3)
      end
      
      it "should keep itself" do
        @session.undo! rescue
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind" do
        lambda{ @session.undo! }.should raise_error(Memento::ErrorOnRewind)
      end
    end
    
    describe "and some states succeed, some fail" do
      before do
        @state1.update_attribute(:record_data, {:name => ["A", "B"]})
        @p1.update_attribute(:name, "C")
      end

      it "should keep all states" do
        @session.undo! rescue nil
        Memento::State.count.should eql(3)
      end

      it "should keep itself" do
        @session.undo! rescue nil
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind" do
        lambda{ @session.undo! }.should raise_error(Memento::ErrorOnRewind)
      end
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