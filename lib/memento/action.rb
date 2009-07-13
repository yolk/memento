module Memento::Action
  class Base
    def initialize(state)
      @state = state
    end
    
    attr_reader :state
    
    def record
      @state.record
    end
    
    def record_data
      @state.record_data
    end
    
    def fetch?
      true
    end
    
    def self.inherited(child)
      action_type = child.name.demodulize.underscore
      write_inheritable_attribute(:action_types, action_types << action_type)
    end
    
    def self.action_types
      read_inheritable_attribute(:action_types) || []
    end
    
    private
    
    def new_object
      object = @state.record_type.constantize.new
      yield(object) if block_given?
      object
    end
  end
end

Dir["#{File.dirname(__FILE__)}/action/*.rb"].each { |action| require action }