class Memento::Action::Update < Memento::Action::Base
  
  def fetch
    record.changes_for_memento
  end
  
  def undo
    if !record
      was_destroyed
    elsif mergable?
      update_record
    else
      was_changed
    end
  end
  
  private
  
  def update_record
    returning(record) do |object|
      record_data.each do |attribute, values|
        object.send(:"#{attribute}=", values.first)
      end
      object.save!
    end
  end
  
  def mergable?
    record_data.all? do |attribute, values|
      # ugly fix to compare times
      values = values.map{|v| v.is_a?(Time) ? v.to_s(:db) : v }
      current_value = record.send(:"#{attribute}")
      current_value = current_value.utc.to_s(:db) if current_value.is_a?(Time)
      
      values.include?(current_value) 
    end || record_data.size.zero?
  end
  
  def was_destroyed
    @state.new_object do |object|
      object.errors.add(:memento_undo, ActiveSupport::StringInquirer.new("was_destroyed"))
      object.id = @state.record_id
    end
  end
  
  def was_changed
    record.errors.add(:memento_undo, ActiveSupport::StringInquirer.new("was_destroyed"))
    record
  end
  
end