class Memento::Action::Destroy < Memento::Action::Base
  
  def fetch
    record.attributes_for_recording
  end
  
  def rewind
    @state.rebuild_object(:id) do |object|
      object.save!
      @state.update_attribute(:record, object)
    end
  end
  
end