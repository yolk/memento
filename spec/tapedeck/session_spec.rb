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
    @session.stub!(:tracks).and_return([t1 = mock("t1"), t2 = mock("t2")])
    t1.should_receive(:rewind).once()
    t2.should_receive(:rewind).once()
    @session.rewind
  end
  
  it "should destroy itself after rewinding " do
    @session.rewind
    Tapedeck::Session.find_by_id(@session.id).should be_nil
  end
  
  describe "with tracks" do
    before do
      @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      @session.tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
      Tapedeck::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => Project.create!)
    end
    
    it "should destroy all tracks when destroyed" do
      Tapedeck::Track.count.should eql(3)
      @session.destroy
      Tapedeck::Track.count.should eql(1)
    end
    
    describe "when rewinded" do
      before do
        @results = @session.rewind
      end
      
      it "should destroy all tracks" do
        @session.rewind
        Tapedeck::Track.count.should eql(1)
      end

      it "should return an Tapedeck::ResultArray containing Tapedeck::Result instances" do
        @results.class.should eql(Tapedeck::ResultArray)
        @results.map(&:class).uniq.should eql([Tapedeck::Result])
      end
    end
    
    
    
  end
  
  
  
  after do
    shutdown_db
  end
  
end