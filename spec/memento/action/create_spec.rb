require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Memento::Action::Create, "when object is created" do
  before do
    setup_db
    setup_data
    Memento.instance.start(@user)
    @project = Project.create!(:name => "P1", :closed_at => 3.days.ago).reload
    Memento.instance.stop
  end
  
  after do
    shutdown_db
  end
    
  it "should create memento_state for ar-object with no data" do
    Memento::State.count.should eql(1)
    Memento::State.first.action_type.should eql("create")
    Memento::State.first.record.should eql(@project) # it was destroyed, remember?
    Memento::State.first.reload.record_data.should eql(nil)
  end
  
  it "should create object" do
    Project.find_by_id(@project.id).should_not be_nil
    Project.count.should eql(1)
  end
  
  it "should allow undoing the creation" do
    Memento::Session.last.undo
    Project.count.should eql(0)
  end
  
  describe "when undoing the creation" do
    it "should give back undone_object" do
      Memento::Session.last.undo.map{|e| e.object.class }.should eql([Project])
    end

    it "should not undo the creatio if object was modified" do
      Project.last.update_attributes(:created_at => 1.minute.ago)
      undone = Memento::Session.last.undo
      Project.count.should eql(1)
      undone.first.should_not be_success
      undone.first.error.first.should be_was_changed
    end
    
    describe "when record was already destroyed" do
      it "should give back fake unsaved record with id set" do
        Project.last.destroy
        @undone = Memento::Session.last.undo
        @undone.size.should eql(1)
        @undone.first.object.should be_kind_of(Project)
        @undone.first.object.id.should eql(@project.id)
        @undone.first.object.name.should be_nil
        @undone.first.object.should be_new_record
        Project.count.should eql(0)
      end
    end
  end
  
  
  
end

describe Memento::Action::Create, "when object without timestamp is created" do
  before do
    setup_db
    setup_data
    Memento.instance.memento(@user) do
      @obj = TimestamplessObject.create!(:name => "O1").reload
    end
  end
  
  after do
    shutdown_db
  end
  
  describe "when undoing the creation" do
    it "should give back undone_object" do
      Memento::Session.last.undo.map{|e| e.object.class }.should eql([TimestamplessObject])
    end
  end
end