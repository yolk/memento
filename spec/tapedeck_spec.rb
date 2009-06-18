require File.join(File.dirname(__FILE__), 'spec_helper')

describe Tapedeck do
  before do
    setup_db
    setup_data
  end
  
  after do
    shutdown_db
  end
  
  it "should be a singleton" do
    Tapedeck.instance.should be_kind_of(Singleton)
    Tapedeck.instance.should eql(Tapedeck.instance)
    lambda{ Tapedeck.new }.should raise_error(NoMethodError)
  end
  
  it "should not be recording by default" do
    Tapedeck.instance.should_not be_recording
  end
  
  describe "start" do
    
    before do
      Tapedeck.instance.start(@user)
      @session = Tapedeck.instance.instance_variable_get("@session")
    end
    
    it "should require user or user_id on start" do
      lambda{ Tapedeck.instance.start }.should raise_error(ArgumentError)
    end
    
    it "should set an unsaved tapedeck_session when starting" do
      Tapedeck::Session.count.should eql(0)
      @session.should be_kind_of(Tapedeck::Session)
      @session.should be_new_record
    end
    
    it "should set user on session" do
      @session.user.should eql(User.first)
    end
    
    it "should set user when passing in id as integer" do
      Tapedeck.instance.start(User.create(:name => "MyUser2").id)
      Tapedeck.instance.instance_variable_get("@session").user.should eql(User.last)
    end
    
    it "should not start recording when user does not exists/is invalid" do
      Tapedeck.instance.stop
      Tapedeck.instance.start(123333)
      Tapedeck.instance.should_not be_recording
      Tapedeck.instance.start("123")
      Tapedeck.instance.should_not be_recording
    end
    
    it "should be recording" do
      Tapedeck.instance.should be_recording
    end
    
  end
  
  describe "stop" do
    before do
      Tapedeck.instance.start(@user)
      Tapedeck.instance.stop
    end
    
    it "should not be recording" do
      Tapedeck.instance.should_not be_recording
    end
    
    it "should remove session if no tracks created" do
      Tapedeck::Session.count.should eql(0)
    end
  end
  
  describe "recording block" do
    
    it "should record inside of block and stop after" do
      Tapedeck.instance.should_not be_recording
      Tapedeck.instance.recording(@user) do
        Tapedeck.instance.should be_recording
      end
      Tapedeck.instance.should_not be_recording
    end
    
    it "should give back session" do
      Tapedeck.instance.recording(@user) do
        1 + 1
      end.should be_a(Tapedeck::Session)
    end
    
    it "should raise error in block and stop session" do
      lambda {
        Tapedeck.instance.recording(@user) do
          raise StandardError
        end.should be_nil
      }.should raise_error(StandardError)
      Tapedeck.instance.should_not be_recording
    end
    
  end
  
  describe "when recording" do
    before do
      @project =  Project.create(:name => "P1")
      Tapedeck.instance.start(@user)
    end
    
    after do
      Tapedeck.instance.stop
    end
    
    it "should create tapedeck_track for ar-object with action_type" do
      Tapedeck::Track.count.should eql(0)
      Tapedeck.instance.add_track :destroy, @project
      Tapedeck::Track.count.should eql(1)
      Tapedeck::Track.first.action_type.should eql("destroy")
      Tapedeck::Track.first.recorded_object.should eql(Project.last)
    end
    
    it "should save session on first added track" do
      Tapedeck::Session.count.should eql(0)
      Tapedeck.instance.add_track :destroy, @project
      Tapedeck::Session.count.should eql(1)
    end
    
  end
  
  describe "when not recording" do
    
    it "should NOT create tapedeck_track for ar-object with action_type" do
      Tapedeck.instance.add_track :destroy, Project.create(:name => "P1")
      Tapedeck::Track.count.should eql(0)
    end
    
  end
  
end