require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Tapedeck::Action::Update, "when object gets updated" do
  before do
    setup_db
    setup_data
    @project = Project.create!(:name => "P1", :closed_at => 3.days.ago, :notes => "Bla bla").reload
    Tapedeck.instance.recording(@user) do
      @customer = Customer.create!(:name => "C1")
      @project.update_attributes(:name => "P2", :closed_at => 2.days.ago, :customer => @customer, :notes => "Bla bla")
    end
  end
  
  after do
    shutdown_db
  end
    
  it "should create tapedeck_track for ar-object from changes_for_recording" do
    Tapedeck::Track.count.should eql(1)
    Tapedeck::Track.first.action_type.should eql("update")
    Tapedeck::Track.first.recorded_object.should eql(@project)
    Tapedeck::Track.first.recorded_data.keys.sort.should eql(%w(name closed_at customer_id).sort)
    Tapedeck::Track.first.recorded_data["name"].should eql(["P1", "P2"])
    Tapedeck::Track.first.recorded_data["customer_id"].should eql([nil, @customer.id])
    Tapedeck::Track.first.recorded_data["closed_at"][0].utc.to_s.should eql(3.days.ago.utc.to_s)
    Tapedeck::Track.first.recorded_data["closed_at"][1].utc.to_s.should eql(2.days.ago.utc.to_s)
  end
  
  it "should update object" do
    @project.reload.name.should eql("P2")
    @project.customer.should eql(@customer)
    @project.closed_at.to_s.should eql(2.days.ago.to_s)
    @project.should_not be_changed
    Project.count.should eql(1)
  end
  
  it "should allow rewinding/undoing the update" do
    rewinded = Tapedeck::Session.last.rewind.first
    rewinded.should be_success
    rewinded.object.should_not be_changed
    rewinded.object.name.should eql("P1")
    rewinded.object.customer.should be_nil
    rewinded.object.closed_at.to_s.should eql(3.days.ago.to_s)
  end
  
  describe "when recorded_object was destroyed before undo" do
    before do
      @project.destroy
    end
    
    it "should return fake object with error" do
      rewinded = Tapedeck::Session.last.rewind.first
      rewinded.should_not be_success
      rewinded.error.should be_was_destroyed
      rewinded.object.class.should eql(Project)
      rewinded.object.id.should eql(1)
    end
  end
  
  describe "when recorded_object was changed before undo" do
    
    describe "with mergeable untracked changes" do
      before do
        @project.update_attributes({:notes => "Bla!"})
        @result = Tapedeck::Session.first.rewind.first
        @object = @result.object
      end
    
      it "should be success" do
        @result.should be_success
      end
    
      it "should return correctly updated object" do
        @object.class.should eql(Project)
        @object.name.should eql("P1")
        @object.customer.should be_nil
        @object.closed_at.to_s.should eql(3.days.ago.to_s)
        @object.notes.should eql("Bla!")
      end
    end
  
    describe "with mergeable tracked changes" do
      before do
        Tapedeck.instance.recording(@user) do
          @project.update_attributes({:notes => "Bla!"})
        end
        Tapedeck::Track.last.update_attribute(:created_at, 1.minute.from_now)
        @result = Tapedeck::Session.first.rewind.first
        @object = @result.object
      end
    
      it "should be success" do
        @result.should be_success
      end
    
      it "should return correctly updated object" do
        @object.class.should eql(Project)
        @object.name.should eql("P1")
        @object.customer.should be_nil
        @object.closed_at.to_s.should eql(3.days.ago.to_s)
        @object.notes.should eql("Bla!")
      end
    
      describe "when second track is rewinded" do
        before do
          @result = Tapedeck::Session.first.rewind.first
          @object = @result.object
        end
    
        it "should be success" do
          @result.should be_success
        end

        it "should return correctly updated object" do
          @object.class.should eql(Project)
          @object.name.should eql("P1")
          @object.customer.should be_nil
          @object.closed_at.to_s.should eql(3.days.ago.to_s)
          @object.notes.should eql("Bla bla")
        end
      end
    end

    describe "with unmergeable untracked changes" do
      before do
        @project.update_attributes({:name => "P3"})
        @result = Tapedeck::Session.last.rewind.first
        @object = @result.object
      end

      it "should fail" do
        @result.should be_failed
      end
    
      it "should return not rewinded object" do
        @object.name.should eql("P3")
        @object.customer.should eql(@customer)
        @object.closed_at.to_s.should eql(2.days.ago.to_s)
        @object.should_not be_changed
      end
    end
    
    describe "with unmergeable tracked changes" do
      before do
        Tapedeck.instance.recording(@user) do
          @project.update_attributes!({:name => "P3"})
        end
        Tapedeck::Track.last.update_attribute(:created_at, 1.minute.from_now)
        @result = Tapedeck::Session.first.rewind.first
        @object = @result.object
      end
    
      it "should fail" do
        @result.should be_failed
      end
    
      it "should return not rewinded object" do
        @object.name.should eql("P3")
        @object.customer.should eql(@customer)
        @object.closed_at.to_s.should eql(2.days.ago.to_s)
        @object.should_not be_changed
      end
      
      describe "when second track is rewinded" do
        before do
          @result = Tapedeck::Session.last.rewind.first
          @object = @result.object
        end
        
        it "should be success" do
          @result.should be_success
        end

        it "should return correctly updated object" do
          @object.class.should eql(Project)
          @object.name.should eql("P2")
          @object.customer.should eql(@customer)
          @object.closed_at.to_s.should eql(2.days.ago.to_s)
          @object.notes.should eql("Bla bla")
        end
      end
    end
  end
  
end