require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tapedeck::Session do
  
  before do
    setup_db
    setup_data
    @session = Tapedeck::Session.create(:user => @user)
  end
  
  it "should belong to user" do
    @session.user.should eql(@user)
  end
  
  it "should require user" do
    Tapedeck::Session.create.errors[:user].should eql("can't be blank")
  end
  
  it "should have_many tracks" do
    @session.tracks.should eql([])
    @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
    @session.tracks.count.should eql(1)
  end
  
  it "should call rewind on all tracks when rewind is called" do
    tracks = [t1 = mock("t1"), t2 = mock("t2")]
    @session.stub!(:tracks).and_return(tracks)
    tracks.stub!(:count).and_return(0)
    t1.should_receive(:rewind).once().and_return(mock("r1", :success? => false))
    t2.should_receive(:rewind).once().and_return(mock("r2", :success? => false))
    @session.rewind
  end
  
  it "should destroy all successful rewinded tracks and keep failed" do
    tracks = [t1 = mock("t1"), t2 = mock("t2")]
    @session.stub!(:tracks).and_return(tracks)
    tracks.stub!(:count).and_return(0)
    t1.should_receive(:rewind).once().and_return(r1 = mock("r1", :success? => true, :track => t1))
    t1.should_receive(:destroy).once().and_return(true)
    t2.should_receive(:rewind).once().and_return(mock("r2", :success? => false))
    @session.rewind
  end
  
  it "should kepp itself if any track failed" do
    tracks = []
    @session.stub!(:tracks).and_return(tracks)
    tracks.stub!(:count).and_return(1) # 1 keept (failed)
    @session.rewind
    @session.reload
  end
  
  it "should destroy itself if all tracks successful" do
    tracks = []
    @session.stub!(:tracks).and_return(tracks)
    tracks.stub!(:count).and_return(0) # 0 keept (failed)
    @session.rewind
    Tapedeck::Session.find_by_id(@session.id).should be_nil
  end
  
  it "should destroy itself after rewinding " do
    @session.rewind
    Tapedeck::Session.find_by_id(@session.id).should be_nil
  end
  
  describe "with tracks" do
    before do
      @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      Tapedeck::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      @track2 = @session.tracks.create!(:action_type => "update", :recorded_object => Project.create!)
    end
    
    it "should destroy all tracks when destroyed" do
      Tapedeck::Track.count.should eql(3)
      @session.destroy
      Tapedeck::Track.count.should eql(1)
    end
    
    describe "on rewind" do
      before do
        @results = @session.rewind
      end
      
      it "should destroy all tracks and session" do
        Tapedeck::Track.count.should eql(1)
        Tapedeck::Session.find_by_id(@session.id).should be_nil
      end

      it "should return an Tapedeck::ResultArray containing Tapedeck::Result instances" do
        @results.class.should eql(Tapedeck::ResultArray)
        @results.map(&:class).uniq.should eql([Tapedeck::Result])
        @results.size.should eql(2)
        @results.should be_success
      end
    end
    
    describe "on partial failed rewind" do
      before do
        @track2.update_attribute(:recorded_data, {:name => ["1", "2"]})
        @track2.recorded_object.update_attribute(:name, "3")
        @results = @session.rewind
      end
      
      it "should return all results" do
        @results.size.should eql(2)
      end
      
      it "should return one failed result" do
        @results.errors.size.should eql(1)
      end
      
      it "should destroy only succesful tracks and keep session" do
        Tapedeck::Track.count.should eql(2)
        @session.reload.tracks.count.should eql(1)
        @session.reload.tracks.first.should eql(@track2)
      end
    end
    
  end
  
  
  
  after do
    shutdown_db
  end
  
end