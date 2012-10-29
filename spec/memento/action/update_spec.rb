require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Memento::Action::Update do
  before do
    setup_db
    setup_data
    @time1 = 3.days.ago
    @time2 = 2.days.ago
    @project = Project.create!(:name => "P1", :closed_at => @time1, :notes => "Bla bla").reload
    @customer = Customer.create!(:name => "C1")
  end

  after do
    shutdown_db
  end

  describe "when object gets updated" do

    before do
      Memento(@user) do
        @project.update_attributes(:name => "P2", :closed_at => @time2, :customer => @customer, :notes => "Bla bla")
      end
    end

    it "should create memento_state for ar-object from changes_for_memento" do
      Memento::State.count.should eql(1)
      Memento::State.first.action_type.should eql("update")
      Memento::State.first.record.should eql(@project)
      Memento::State.first.record_data.keys.sort.should eql(%w(name closed_at customer_id).sort)
      Memento::State.first.record_data["name"].should eql(["P1", "P2"])
      Memento::State.first.record_data["customer_id"].should eql([nil, @customer.id])
      Memento::State.first.record_data["closed_at"][0].utc.to_s.should eql(@time1.utc.to_s)
      Memento::State.first.record_data["closed_at"][1].utc.to_s.should eql(@time2.utc.to_s)
    end

    it "should update object" do
      @project.reload.name.should eql("P2")
      @project.customer.should eql(@customer)
      @project.closed_at.to_s.should eql(@time2.to_s)
      @project.should_not be_changed
      Project.count.should eql(1)
    end

    it "should allow undoing the update" do
      undone = Memento::Session.last.undo.first
      undone.should be_success
      undone.object.should_not be_changed
      undone.object.name.should eql("P1")
      undone.object.customer.should be_nil
      undone.object.closed_at.to_s.should eql(@time1.to_s)
    end

    describe "when record was destroyed before undo" do
      before do
        @project.destroy
      end

      it "should return fake object with error" do
        undone = Memento::Session.last.undo.first
        undone.should_not be_success
        undone.error.first.should be_was_destroyed
        undone.object.class.should eql(Project)
        undone.object.id.should eql(1)
      end
    end

    describe "when record was changed before undo" do

      describe "with mergeable unrecorded changes" do
        before do
          @project.update_attributes({:notes => "Bla!"})
          @result = Memento::Session.first.undo.first
          @object = @result.object
        end

        it "should be success" do
          @result.should be_success
        end

        it "should return correctly updated object" do
          @object.class.should eql(Project)
          @object.name.should eql("P1")
          @object.customer.should be_nil
          @object.closed_at.to_s.should eql(@time1.to_s)
          @object.notes.should eql("Bla!")
        end
      end

      describe "with mergeable recorded changes" do
        before do
          Memento(@user) do
            @project.update_attributes({:notes => "Bla\nBla!"})
          end
          Memento::State.last.update_attributes(:created_at => 1.minute.from_now)
          @result = Memento::Session.first.undo.first
          @object = @result.object
        end

        it "should be success" do
          @result.should be_success
        end

        it "should return correctly updated object" do
          @object.class.should eql(Project)
          @object.name.should eql("P1")
          @object.customer.should be_nil
          @object.closed_at.to_s.should eql(@time1.to_s)
          @object.notes.should eql("Bla\nBla!")
        end

        describe "when second state is undone" do
          before do
            @result = Memento::Session.first.undo.first
            @object = @result.object
          end

          it "should be success" do
            @result.should be_success
          end

          it "should return correctly updated object" do
            @object.class.should eql(Project)
            @object.name.should eql("P1")
            @object.customer.should be_nil
            @object.closed_at.to_s.should eql(@time1.to_s)
            @object.notes.should eql("Bla bla")
          end
        end
      end

      describe "with unmergeable unrecorded changes" do
        before do
          @project.update_attributes({:name => "P3"})
          @result = Memento::Session.last.undo.first
          @object = @result.object
        end

        it "should fail" do
          @result.should be_failed
        end

        it "should set error" do
          @result.error.first.should be_was_changed
        end

        it "should return not undone object" do
          @object.name.should eql("P3")
          @object.customer.should eql(@customer)
          @object.closed_at.to_s.should eql(@time2.to_s)
          @object.should_not be_changed
        end
      end

      describe "with unmergeable recorded changes" do
        before do
          Memento(@user) do
            @project.update_attributes!({:name => "P3"})
          end
          Memento::State.last.update_attributes(:created_at => 1.minute.from_now)
          @result = Memento::Session.first.undo.first
          @object = @result.object
        end

        it "should fail" do
          @result.should be_failed
        end

        it "should return not undone object" do
          @object.name.should eql("P3")
          @object.customer.should eql(@customer)
          @object.closed_at.to_s.should eql(@time2.to_s)
          @object.should_not be_changed
        end

        describe "when second state is undone" do
          before do
            @result = Memento::Session.last.undo.first
            @object = @result.object
          end

          it "should be success" do
            @result.should be_success
          end

          it "should return correctly updated object" do
            @object.class.should eql(Project)
            @object.name.should eql("P2")
            @object.customer.should eql(@customer)
            @object.closed_at.to_s.should eql(@time2.to_s)
            @object.notes.should eql("Bla bla")
          end
        end
      end
    end

  end

  describe "when object gets updated with no changes" do

    before do
      Memento(@user) do
        @project.update_attributes(:name => "P1", :customer => nil, :notes => "Bla bla")
      end
    end

    it "should not create session/state" do
      Memento::Session.count.should eql(0)
      Memento::State.count.should eql(0)
    end

  end

end