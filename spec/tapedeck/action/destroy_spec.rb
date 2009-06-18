require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Tapedeck::Action::Destroy, "when object gets destroyed" do
  before do
    setup_db
    setup_data
    @project = Project.create!(:name => "P1", :closed_at => 3.days.ago).reload
    Tapedeck.instance.start(@user)
    @project.destroy
  end
  
  after do
    Tapedeck.instance.stop
    shutdown_db
  end
    
  it "should create tapedeck_track for ar-object with full attributes_for_recording" do
    Tapedeck::Track.count.should eql(1)
    Tapedeck::Track.first.action_type.should eql("destroy")
    Tapedeck::Track.first.recorded_object.should be_nil # it was destroyed, remember?
    Tapedeck::Track.first.reload.recorded_data.should == @project.attributes_for_recording
  end
  
  it "should destroy object" do
    Project.find_by_id(@project.id).should be_nil
    Project.count.should be_zero
  end
  
  it "should allow rewinding/undoing the destruction" do
    Project.count.should be_zero
    Tapedeck::Session.last.rewind
    Project.count.should eql(1)
    Project.first.attributes_for_recording.reject{|k, v| k.to_sym == :id }.should == (
      @project.attributes_for_recording.reject{|k, v| k.to_sym == :id }
    )
  end
  
  it "should give back rewinded_object on rewinding/undoing the destruction" do
    Tapedeck::Session.last.rewind.map{|e| e.object.class }.should eql([Project])
  end
  
  
end