module Memento
  class State < ActiveRecord::Base
    self.table_name = "memento_states"

    belongs_to :session, :class_name => "Memento::Session"
    belongs_to :record, :polymorphic => true

    validates_presence_of :session
    validates_presence_of :record
    validates_presence_of :action_type
    validates_inclusion_of :action_type, :in => Memento::Action::Base.action_types, :allow_blank => true

    def self.add(action_type, record)
      state = new do |state|
        state.action_type = action_type.to_s
        state.record = record
      end
      if state.fetch?
        state.record_data = action.fetch
        state
      else
        nil
      end
    end

    def undo
      Memento::Result.new(action.undo, self)
    end

    def record_data
      @record_data ||= begin
        raw = read_attribute(:record_data)
        if raw.blank?
          {}
        else
          data = Memento.serializer.load(raw)
          data.is_a?(Hash) ? data.with_indifferent_access : data
        end
      end
    end

    def record_data=(data)
      @record_data = nil
      write_attribute(:record_data, data.is_a?(String) ? data :
        Memento.serializer.dump(data.is_a?(Hash) ? data.to_hash : data)
      )
    end

    def fetch?
      action.fetch?
    end

    private

    def action
      "memento/action/#{action_type}".classify.constantize.new(self)
    end
  end
end
