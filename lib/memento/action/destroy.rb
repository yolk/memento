module Memento
  class Action::Destroy < Memento::Action::Base

    def fetch
      record.attributes_for_memento
    end

    def undo
      rebuild_object do |object|
        object.send(:memento_before_save_on_undo) if object.respond_to?(:memento_before_save_on_undo, true)
        begin
          object.save!
        rescue
          object.id = nil
          object.save!
        end
        state.record = object
        state.save
      end
    end

    private

    def rebuild_object
      new_object do |object|
        state.record_data.each do |attribute, value|
          object.send(:"#{attribute}=", value)
        end
        yield(object) if block_given?
      end
    end
  end
end
