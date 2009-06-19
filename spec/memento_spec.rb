require File.join(File.dirname(__FILE__), 'spec_helper')

describe Memento do
  before do
    setup_db
    setup_data
  end
  
  after do
    shutdown_db
  end
  
  it "should be a singleton" do
    Memento.instance.should be_kind_of(Singleton)
    Memento.instance.should eql(Memento.instance)
    lambda{ Memento.new }.should raise_error(NoMethodError)
  end
  
  it "should not be memento by default" do
    Memento.instance.should_not be_active
  end
  
  describe "start" do
    
    before do
      Memento.instance.start(@user)
      @session = Memento.instance.instance_variable_get("@session")
    end
    
    it "should require user or user_id on start" do
      lambda{ Memento.instance.start }.should raise_error(ArgumentError)
    end
    
    it "should set an unsaved memento_session when starting" do
      Memento::Session.count.should eql(0)
      @session.should be_kind_of(Memento::Session)
      @session.should be_new_record
    end
    
    it "should set user on session" do
      @session.user.should eql(User.first)
    end
    
    it "should set user when passing in id as integer" do
      Memento.instance.start(User.create(:name => "MyUser2").id)
      Memento.instance.instance_variable_get("@session").user.should eql(User.last)
    end
    
    it "should not start memento when user does not exists/is invalid" do
      Memento.instance.stop
      Memento.instance.start(123333)
      Memento.instance.should_not be_active
      Memento.instance.start("123")
      Memento.instance.should_not be_active
    end
    
    it "should be memento" do
      Memento.instance.should be_active
    end
    
  end
  
  describe "stop" do
    before do
      Memento.instance.start(@user)
      Memento.instance.stop
    end
    
    it "should not be memento" do
      Memento.instance.should_not be_active
    end
    
    it "should remove session if no states created" do
      Memento::Session.count.should eql(0)
    end
  end
  
  describe "memento block" do
    
    it "should record inside of block and stop after" do
      Memento.instance.should_not be_active
      Memento.instance.memento(@user) do
        Memento.instance.should be_active
      end
      Memento.instance.should_not be_active
    end
    
    it "should give back session when states created" do
      Memento.instance.memento(@user) do
        Project.create!
      end.should be_a(Memento::Session)
    end
    
    it "should give back false when no states created" do
      Memento.instance.memento(@user) do
        1 + 1
      end.should be_false
    end
    
    it "should raise error in block and stop session" do
      lambda {
        Memento.instance.memento(@user) do
          raise StandardError
        end.should be_nil
      }.should raise_error(StandardError)
      Memento.instance.should_not be_active
    end
    
  end
  
  describe "when memento" do
    before do
      @project =  Project.create(:name => "P1")
      Memento.instance.start(@user)
    end
    
    after do
      Memento.instance.stop
    end
    
    it "should create memento_state for ar-object with action_type" do
      Memento::State.count.should eql(0)
      Memento.instance.add_state :destroy, @project
      Memento::State.count.should eql(1)
      Memento::State.first.action_type.should eql("destroy")
      Memento::State.first.record.should eql(Project.last)
    end
    
    it "should save session on first added state" do
      Memento::Session.count.should eql(0)
      Memento.instance.add_state :destroy, @project
      Memento::Session.count.should eql(1)
    end
    
  end
  
  describe "when not memento" do
    
    it "should NOT create memento_state for ar-object with action_type" do
      Memento.instance.add_state :destroy, Project.create(:name => "P1")
      Memento::State.count.should eql(0)
    end
    
  end
  
end