require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Memento::Action::Destroy, "when object gets destroyed" do
  before do
    setup_db
    setup_data
    @project = Project.create!(:name => "P1", :closed_at => 3.days.ago).reload
    Memento.start(@user)
    @project.destroy
    Memento.stop
  end

  after do
    shutdown_db
  end

  it "should create memento_state for ar-object with full attributes_for_memento" do
    Memento::State.count.should eql(1)
    Memento::State.first.action_type.should eql("destroy")
    Memento::State.first.record.should be_nil # it was destroyed, remember?
    Memento::State.first.reload.record_data.should == @project.attributes_for_memento
  end

  it "should destroy object" do
    Project.where(:id => @project.id).first.should be_nil
    Project.count.should be_zero
  end

  it "should allow undoing the destruction" do
    Project.count.should be_zero
    Memento::Session.last.undo
    Project.count.should eql(1)
    Project.first.attributes_for_memento.reject{|k, v| k.to_sym == :id }.should == (
      @project.attributes_for_memento.reject{|k, v| k.to_sym == :id }
    )
  end

  it "should give back undone_object on undoing the destruction" do
    Memento::Session.last.undo.map{|e| e.object.class }.should eql([Project])
  end


end
