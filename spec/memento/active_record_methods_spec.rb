require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Memento::ActiveRecordMethods do

  before do
    setup_db
    setup_data
  end

  it "should declare protected methods on Project" do
    Project.private_instance_methods.map(&:to_sym).should include(:record_destroy, :record_update, :record_create)
  end

  it "should set hook on create to call Memento" do
    project = Project.new(:name => "Project X")
    Memento.should_receive(:add_state).once().with("create", project)
    project.save!
  end

  it "should set hook on update to call Memento" do
    project = Project.create!(:name => "Project X")
    Memento.should_receive(:add_state).once().with("update", project)
    project.update_attributes(:name => "Project XY")
  end

  it "should set hook on destroy to call Memento" do
    project = Project.create!(:name => "Project X")
    Memento.should_receive(:add_state).once().with("destroy", project)
    project.destroy
  end

  it "should define attributes_for_memento and ignore attributes given by options" do
    Project.create!(:name => "Project X").attributes_for_memento.should == {
      "id"=>1, "name"=>"Project X", "notes"=>nil, "customer_id"=>nil, "closed_at"=>nil
    }
  end

  it "should set memento_options" do
    Project.memento_options.should eql({:ignore=>[:ignore_this]})
  end

  it "should define changes_for_memento and ignore attributes given by options" do
    project = Project.create!(:name => "Project X")
    project.name = "A Project"
    project.updated_at = 5.minutes.ago
    project.notes = "new"
    project.ignore_this = 2
    project.changes_for_memento.should_not == project.changes
    project.changes_for_memento.should == {"name"=>["Project X", "A Project"], "notes"=>[nil, "new"]}
  end

  it "should define has_many association to memento_states" do
    project = Project.create!(:name => "Project X")
    project.memento_states.should be_empty
    Memento(@user) { project.update_attributes(:name => "Project Y") }
    project.memento_states.count.should eql(1)
    Memento(@user) { project.update_attributes(:name => "Project Y") }
    project.memento_states.count.should eql(1)
    Memento(@user) { Project.create!.update_attributes(:name => "Project X") }
    project.memento_states.count.should eql(1)
    Project.last.memento_states.count.should eql(2)
    Memento::State.count.should eql(3)
  end

  after do
    shutdown_db
  end

end