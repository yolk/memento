require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Tapedeck::Action::Create, "when object is created" do
  before do
    setup_db
    setup_data
    Tapedeck.instance.start(@user)
    @project = Project.create!(:name => "P1", :closed_at => 3.days.ago).reload
    Tapedeck.instance.stop
  end
  
  after do
    shutdown_db
  end
    
  it "should create tapedeck_track for ar-object with no data" do
    Tapedeck::Track.count.should eql(1)
    Tapedeck::Track.first.action_type.should eql("create")
    Tapedeck::Track.first.recorded_object.should eql(@project) # it was destroyed, remember?
    Tapedeck::Track.first.reload.recorded_data.should eql(nil)
  end
  
  it "should create object" do
    Project.find_by_id(@project.id).should_not be_nil
    Project.count.should eql(1)
  end
  
  it "should allow rewinding/undoing the creation" do
    Tapedeck::Session.last.rewind
    Project.count.should eql(0)
  end
  
  describe "when rewinding/undoing the creation" do
    it "should give back rewinded_object" do
      Tapedeck::Session.last.rewind.map{|e| e.object.class }.should eql([Project])
    end

    it "should not rewind the creatio if object was modified" do
      Project.last.update_attribute(:created_at, 1.minute.ago)
      rewinded = Tapedeck::Session.last.rewind
      Project.count.should eql(1)
      rewinded.first.should_not be_success
      rewinded.first.error.should be_was_changed
    end
    
    describe "when recorded_object was already destroyed" do
      
      it "should give back fake unsaved record with id set" do
        Project.last.destroy
        @rewinded = Tapedeck::Session.last.rewind
        @rewinded.size.should eql(1)
        @rewinded.first.object.should be_kind_of(Project)
        @rewinded.first.object.id.should eql(@project.id)
        @rewinded.first.object.name.should be_nil
        @rewinded.first.object.should be_new_record
        Project.count.should eql(0)
      end
    
      it "should give back fake unsaved record with all data set when destruction was tracked" do
        Tapedeck.instance.record(@user) { Project.last.destroy }
        Tapedeck::Track.last.update_attribute(:created_at, 5.minutes.from_now)
        @rewinded = Tapedeck::Session.first.rewind
        @rewinded.size.should eql(1)
        @rewinded.first.object.should be_kind_of(Project)
        @rewinded.first.object.id.should eql(@project.id)
        @rewinded.first.object.name.should eql(@project.name)
        @rewinded.first.object.closed_at.should eql(@project.closed_at)
        @rewinded.first.object.should be_new_record
        Project.count.should eql(0)
      end
    end
  end
  
  
  
end