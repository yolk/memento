class Memento::Action::Destroy < Memento::Action::Base
  
  def record
    recorded_object.attributes_for_recording
  end
  
  def rewind
    @state.rebuild_object(:id) do |object|
      object.save!
      @state.update_attribute(:recorded_object, object)
    end
  end
  
end