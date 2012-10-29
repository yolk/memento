require File.join(File.dirname(__FILE__), 'spec_helper')

describe Memento do
  before do
    setup_db
    setup_data
  end

  after do
    shutdown_db
  end

  it "should be (like) a singleton" do
    Memento.instance.should eql(Memento.instance)
    Memento.instance.should eql(Memento)
    lambda{ Memento.new }.should raise_error(NoMethodError)
  end

  it "should not be memento by default" do
    Memento.should_not be_active
  end

  describe "start" do

    before do
      Memento.start(@user)
      @session = Memento.send(:session)
    end

    it "should require user or user_id on start" do
      lambda{ Memento.start }.should raise_error(ArgumentError)
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
      Memento.start(User.create(:name => "MyUser2").id)
      Memento.send(:session).user.should eql(User.last)
    end

    it "should not start memento when user does not exists/is invalid" do
      Memento.stop
      Memento.start(123333)
      Memento.should_not be_active
      Memento.start("123")
      Memento.should_not be_active
    end

    it "should be memento" do
      Memento.should be_active
    end

  end

  describe "stop" do
    before do
      Memento.start(@user)
      Memento.stop
    end

    it "should not be memento" do
      Memento.should_not be_active
    end

    it "should remove session if no states created" do
      Memento::Session.count.should eql(0)
    end
  end

  describe "memento block" do

    it "should record inside of block and stop after" do
      Memento.should_not be_active
      Memento(@user) do
        Memento.should be_active
      end
      Memento.should_not be_active
    end

    it "should give back session when states created" do
      Memento(@user) do
        Project.create!
      end.should be_a(Memento::Session)
    end

    it "should give back false when no states created" do
      Memento(@user) do
        1 + 1
      end.should be_false
    end

    it "should raise error in block and stop session" do
      lambda {
        Memento(@user) do
          raise StandardError
        end.should be_nil
      }.should raise_error(StandardError)
      Memento.should_not be_active
    end

  end

  describe "when active" do
    before do
      @project =  Project.create(:name => "P1")
      Memento.start(@user)
    end

    after do
      Memento.stop
    end

    it "should create memento_state for ar-object with action_type" do
      Memento::State.count.should eql(0)
      Memento.add_state :destroy, @project
      Memento::State.count.should eql(1)
      Memento::State.first.action_type.should eql("destroy")
      Memento::State.first.record.should eql(Project.last)
    end

    it "should save session on first added state" do
      Memento::Session.count.should eql(0)
      Memento.add_state :destroy, @project
      Memento::Session.count.should eql(1)
    end

    describe "when ignoring" do
      it "should NOT create memento_state for ar-object with action_type" do
        Memento.ignore do
          Memento.add_state :destroy, Project.create(:name => "P1")
        end

        Memento::State.count.should eql(0)
      end
    end

  end

  describe "when not active" do

    it "should NOT create memento_state for ar-object with action_type" do
      Memento.add_state :destroy, Project.create(:name => "P1")
      Memento::State.count.should eql(0)
    end

  end

  context "serializer" do

    it "should default to yaml" do
      Memento.serializer.should eql(YAML)
    end

    it "should be changeable" do
      Memento.serializer = Marshal
      Memento.serializer.should eql(Marshal)
    end

  end

  describe "multiple threads" do
    describe "start" do
      before do
        Thread.new do
          Memento.start(@user)
        end
      end

      it "should start Memento not in main thread" do
        sleep(0.1)
        Memento.should_not be_active
      end

      it "should start Memento not in separat thread" do
        sleep(0.1)
        t = Thread.new do
          Memento.should_not be_active
        end
        t.join
      end
    end

    describe "ignore" do
      before do
        @t = Thread.new do
          Memento.ignore { Memento.should be_ignore;sleep(0.2) }
        end
      end

      after do
        @t.join
      end

      it "should set ignore status by thread" do
        Memento.should_not be_ignore
        sleep(0.1)
        Memento.should_not be_ignore
      end
    end
  end

end