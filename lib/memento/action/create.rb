class Memento::Action::Create < Memento::Action::Base
  
  def fetch;end
  
  def undo
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
    record.updated_at > record.created_at rescue false
  end
  
  def build_fake_object
    new_object do |object|
      object.id = state.record_id
    end
  end
  
  def was_changed
    record.errors.add(:memento_undo, ActiveSupport::StringInquirer.new("was_changed"))
    record
  end
  
  def destroy_record
    record.destroy
    record
  end
  
end