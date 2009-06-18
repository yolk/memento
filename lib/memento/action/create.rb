class Memento::Action::Create < Memento::Action::Base
  
  def record;end
  
  def rewind
    if recorded_object.nil?
      build_fake_object
    elsif recorded_object_was_changed?
      was_changed
    else
      destroy_recorded_object
    end
  end
  
  private
  
  def recorded_object_was_changed?
    recorded_object.updated_at > recorded_object.created_at
  end
  
  def build_fake_object
    if destroy_state = @state.later_states_on_recorded_object_for(:destroy).last
      destroy_state.rebuild_object
    else
      @state.new_object do |object|
        object.id = @state.recorded_object_id
      end
    end
  end
  
  def was_changed
    recorded_object.errors.add(:memento_rewind, ActiveSupport::StringInquirer.new("was_changed"))
    recorded_object
  end
  
  def destroy_recorded_object
    recorded_object.destroy
    recorded_object
  end
  
end