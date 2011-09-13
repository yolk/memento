class Memento::Action::Update < Memento::Action::Base
  
  def fetch
    record.changes_for_memento
  end
  
  def fetch?
    record.changes_for_memento.any?
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
    record.tap do |object|
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
      values.include?(current_value) || (current_value.is_a?(String) && values.include?(current_value.gsub(/\r\n/, "\n")))
    end || record_data.size.zero?
  end
  
  def was_destroyed
    new_object do |object|
      object.errors[:memento_undo] << ActiveSupport::StringInquirer.new("was_destroyed")
      object.id = state.record_id
    end
  end
  
  def was_changed
    record.errors[:memento_undo] << ActiveSupport::StringInquirer.new("was_changed")
    record
  end
  
end