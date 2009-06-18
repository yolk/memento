require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::RecordChanges do
  
  before do
    setup_db
    setup_data
  end
  
  it "should declare private methods on Project" do
    Project.private_instance_methods.should include("record_destroy", "record_update", "record_create")
  end
  
  it "should set hook on create to call Memento" do
    project = Project.new(:name => "Project X")
    Memento.instance.should_receive(:add_track).once().with("create", project)
    project.save!
  end
  
  it "should set hook on update to call Memento" do
    project = Project.create!(:name => "Project X")
    Memento.instance.should_receive(:add_track).once().with("update", project)
    project.update_attribute(:name, "Project XY")
  end
  
  it "should set hook on destroy to call Memento" do
    project = Project.create!(:name => "Project X")
    Memento.instance.should_receive(:add_track).once().with("destroy", project)
    project.destroy
  end
  
  it "should define attributes_for_recording and ignore attributes" do
    Project.create!(:name => "Project X").attributes_for_recording.should == {
      "id"=>1, "name"=>"Project X", "notes"=>nil, "customer_id"=>nil, "closed_at"=>nil
    }
  end
  
  it "should define changes_for_recording and ignore attributes" do
    project = Project.create!(:name => "Project X")
    project.name = "A Project"
    project.updated_at = 5.minutes.ago
    project.notes = "new"
    project.changes_for_recording.should_not == project.changes
    project.changes_for_recording.should == {"name"=>["Project X", "A Project"], "notes"=>[nil, "new"]}
  end
  
  it "should define has_many association to memento_tracks" do
    project = Project.create!(:name => "Project X")
    project.memento_tracks.should be_empty
    Memento.instance.recording(@user) { project.update_attribute(:name, "Project X") }
    project.memento_tracks.count.should eql(1)
    Memento.instance.recording(@user) { Project.create!.update_attribute(:name, "Project X") }
    project.memento_tracks.count.should eql(1)
    Project.last.memento_tracks.count.should eql(2)
    Memento::Track.count.should eql(3)
  end
  
  after do
    shutdown_db
  end
  
end