class Memento::Action::Create < Memento::Action::Base
  
  def fetch;end
  
  def rewind
    if record.nil?
      build_fake_object
    elsif record_was_changed?
      was_changed
    else
      destroy_record
    end
  end
  
  private
  
  def record_was_changed?
    record.updated_at > record.created_at
  end
  
  def build_fake_object
    if destroy_state = @state.later_states_on_record_for(:destroy).last
      destroy_state.rebuild_object
    else
      @state.new_object do |object|
        object.id = @state.record_id
      end
    end
  end
  
  def was_changed
    record.errors.add(:memento_rewind, ActiveSupport::StringInquirer.new("was_changed"))
    record
  end
  
  def destroy_record
    record.destroy
    record
  end
  
end