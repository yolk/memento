class Memento::Action::Destroy < Memento::Action::Base
  
  def fetch
    record.attributes_for_memento
  end
  
  def undo
    rebuild_object do |object|
      begin
        object.save!
      rescue
        object.id = nil
        object.save!
      end
      state.update_attribute(:record, object)
    end
  end
  
end