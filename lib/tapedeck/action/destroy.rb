class Tapedeck::Action::Destroy < Tapedeck::Action::Base
  
  def record
    recorded_object.attributes_for_recording
  end
  
  def rewind
    @track.rebuild_object(:id) do |object|
      object.save!
      @track.update_attribute(:recorded_object, object)
    end
  end
  
end