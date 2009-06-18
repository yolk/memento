class Memento::Action::Update < Memento::Action::Base
  
  def record
    recorded_object.changes_for_recording
  end
  
  def rewind
    if !recorded_object
      was_destroyed
    elsif mergable?
      update_recorded_object
    else
      was_changed
    end
  end
  
  private
  
  def update_recorded_object
    returning(recorded_object) do |object|
      recorded_data.each do |attribute, values|
        object.send(:"#{attribute}=", values.first)
      end
      object.save!
    end
  end
  
  def mergable?
    recorded_data.all? do |attribute, values|
      # ugly fix to compare times
      values = values.map{|v| v.is_a?(Time) ? v.to_s(:db) : v }
      current_value = recorded_object.send(:"#{attribute}")
      current_value = current_value.utc.to_s(:db) if current_value.is_a?(Time)
      
      values.include?(current_value) 
    end || recorded_data.size.zero?
  end
  
  def was_destroyed
    @state.new_object do |object|
      object.errors.add(:memento_rewind, ActiveSupport::StringInquirer.new("was_destroyed"))
      object.id = @state.recorded_object_id
    end
  end
  
  def was_changed
    recorded_object.errors.add(:memento_rewind, ActiveSupport::StringInquirer.new("was_destroyed"))
    recorded_object
  end
  
end