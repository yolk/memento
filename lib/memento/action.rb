module Memento::Action
  
  class Base
    def initialize(state)
      @state = state
    end
    
    def record
      @state.record
    end
    
    def record_data
      @state.record_data
    end
    
    def self.inherited(child)
      action_type = child.name.demodulize.underscore
      write_inheritable_attribute(:action_types, action_types << action_type)
    end
    
    def self.action_types
      read_inheritable_attribute(:action_types) || []
    end
  end
  
end

Dir["#{File.dirname(__FILE__)}/action/*.rb"].each { |action| require action }