require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::Track do
  
  before do
    setup_db
    setup_data
    @session = Memento::Session.create(:user => @user)
  end
  
  it "should belong to session" do
    Memento::Track.new(:session => @session).session.should eql(@session)
  end
  
  it "should require session" do
    Memento::Track.create.errors[:session].should eql("can't be blank")
  end
  
  it "should require action_type to be one of Memento::Track::RECORD_CAUSES" do
    Memento::Track.create.errors[:action_type].should eql("can't be blank")
    Memento::Track.create(:action_type => "move").errors[:action_type].should eql("is not included in the list")
  end
  
  it "should belong to polymorphic recorded_object" do
    Memento::Track.new(:recorded_object => @user).recorded_object.should eql(@user)
    Memento::Track.new(:recorded_object => @session).recorded_object.should eql(@session)
  end
  
  it "should require recorded_object" do
    Memento::Track.create.errors[:recorded_object].should eql("can't be blank")
  end
  
  
  describe "valid Track" do
    before do
      @track = @session.tracks.create!(:action_type => "destroy", :recorded_object => @project = Project.create(:name => "A") )
    end
    
    it "should give back Memento::Result on rewind" do
      result = @track.rewind
      result.should be_a(Memento::Result)
      result.object.should be_a(Project)
      result.track.should eql(@track)
    end
    
    it "should give back old data on recorded_data" do
      @track.recorded_data.should == (@project.attributes_for_recording)
    end
    
    it "should give back new unsaved copy of object on new_object" do
      @track.new_object.should be_kind_of(Project)
      @track.new_object.name.should be_nil
      @track.new_object do |object|
        object.name = "B"
      end.name.should eql("B")
    end
    
    it "should give back new unsaved copy filled with old data of object on rebuild_object" do
      @track.rebuild_object.should be_kind_of(Project)
      @track.rebuild_object.name.should eql("A")
      @track.rebuild_object(:id).id.should be_nil # skip id
      @track.rebuild_object.id.should eql(@project.id)
      @track.rebuild_object do |object|
        object.name = "B"
      end.name.should eql("B")
    end
    
    describe "on later_tracks_on_recorded_object_for" do
      
      it "should return empty array" do
        @track.later_tracks_on_recorded_object_for("destroy").should eql([])
      end

      it "should return filled array when other record of the given action_type exists" do
        Memento::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => @project )
        @track.later_tracks_on_recorded_object_for("destroy").map(&:class).should eql([Memento::Track])
        @track.later_tracks_on_recorded_object_for(:"destroy").map(&:id).should eql([2])
      end
      
      it "should return empty array when only records of another action_type exists" do
        Memento::Session.create!(:user => @user).tracks.create!(:action_type => "update", :recorded_object => @project )
        @track.later_tracks_on_recorded_object_for("destroy").should eql([])
      end
      
      it "should return empty array when only destroy records of another recorded_object exists" do
        Memento::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => Project.create(:name => "B") )
        @track.later_tracks_on_recorded_object_for("destroy").should eql([])
      end
      
      it "should return empty array when only destroy records older than @tack exist" do
        track2 = Memento::Session.create!(:user => @user).tracks.create!(:action_type => "destroy", :recorded_object => @project )
        track2.update_attribute(:created_at, 3.minutes.ago)
        @track.later_tracks_on_recorded_object_for("destroy").should eql([])
      end
    end
    
    
    
  end
  
  after do
    shutdown_db
  end
  
end