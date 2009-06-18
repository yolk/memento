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
  
  it "should have_many tracks" do
    @session.tracks.should eql([])
    @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
    @session.tracks.count.should eql(1)
  end
  
  describe "on rewind" do
    before do
      @tracks = [@t1 = mock("t1"), @t2 = mock("t2")]
      @session.stub!(:tracks).and_return(@tracks)
    end
    
    describe "and all tracks fail" do
      before do
        @t1.stub!(:rewind).once().and_return(mock("r1", :success? => false))
        @t2.stub!(:rewind).once().and_return(mock("r2", :success? => false))
        @tracks.stub!(:count).and_return(2)
      end
      
      it "should call rewind on all tracks when rewind is called" do
        @t1.should_receive(:rewind).once().and_return(mock("r1", :success? => false))
        @t2.should_receive(:rewind).once().and_return(mock("r2", :success? => false))
        @session.rewind
      end
      
      it "should kepp itself" do
        @session.rewind
        @session.reload
      end
    end
    
    describe "and all tracks succeed" do
      before do
        @t1.stub!(:rewind).once().and_return(mock("r1", :success? => true, :track => @t1))
        @t2.stub!(:rewind).once().and_return(mock("r2", :success? => true, :track => @t2))
        @t1.stub!(:destroy).once()
        @t2.stub!(:destroy).once()
        @tracks.stub!(:count).and_return(0)
      end
      
      it "should destroy itself" do
        @session.rewind
        Memento::Session.find_by_id(@session.id).should be_nil
      end
      
      it "should destroy all tracks" do
        @t1.should_receive(:destroy).once()
        @t2.should_receive(:destroy).once()
        @session.rewind
      end
    end
    
    describe "and some tracks succeed, some fail" do
      before do
        @t1.stub!(:rewind).once().and_return(mock("r1", :success? => true, :track => @t1))
        @t2.stub!(:rewind).once().and_return(mock("r2", :success? => false, :track => @t2))
        @t1.stub!(:destroy).once()
        @tracks.stub!(:count).and_return(1)
      end
      
      it "should kepp itself" do
        @session.rewind
        @session.reload
      end
      
      it "should destroy only successful tracks" do
        @t1.should_receive(:destroy).once()
        @t2.should_receive(:destroy).never()
        @session.rewind
      end
    end
  end
  
  describe "on rewind!" do
    before do
      @track1 = @session.tracks.create!(:action_type => "update", :recorded_object => @p1 = Project.create!)
      Memento::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      @track2 = @session.tracks.create!(:action_type => "update", :recorded_object => @p2 = Project.create!)
    end
    
    describe "and all tracks succeed" do
      it "should return ResultsArray" do
        @session.rewind!.should be_a(Memento::ResultArray)
      end
      
      it "should remove all tracks" do
        @session.rewind!
        Memento::Track.count.should eql(1)
      end
      
      it "should remove itself" do
        @session.rewind!
        Memento::Session.find_by_id(@session.id).should be_nil
      end
    end
    
    describe "and all tracks fail" do
      before do
        @track1.update_attribute(:recorded_data, {:name => ["A", "B"]})
        @p1.update_attribute(:name, "C")
        @track2.update_attribute(:recorded_data, {:name => ["A", "B"]})
        @p2.update_attribute(:name, "C")
      end
      
      it "should keep all tracks" do
        @session.rewind! rescue
        Memento::Track.count.should eql(3)
      end
      
      it "should keep itself" do
        @session.rewind! rescue
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind" do
        lambda{ @session.rewind! }.should raise_error(Memento::ErrorOnRewind)
      end
    end
    
    describe "and some tracks succeed, some fail" do
      before do
        @track1.update_attribute(:recorded_data, {:name => ["A", "B"]})
        @p1.update_attribute(:name, "C")
      end

      it "should keep all tracks" do
        @session.rewind! rescue nil
        Memento::Track.count.should eql(3)
      end

      it "should keep itself" do
        @session.rewind! rescue nil
        @session.reload
      end
      
      it "should raise Memento::ErrorOnRewind" do
        lambda{ @session.rewind! }.should raise_error(Memento::ErrorOnRewind)
      end
    end
  end
  
  describe "with tracks" do
    before do
      @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      Memento::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      @track2 = @session.tracks.create!(:action_type => "update", :recorded_object => Project.create!)
    end
    
    it "should destroy all tracks when destroyed" do
      Memento::Track.count.should eql(3)
      @session.destroy
      Memento::Track.count.should eql(1)
    end
    
  end
  
  
  
  after do
    shutdown_db
  end
  
end