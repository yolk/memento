module Memento::Action
  
  class Base
    def initialize(state)
      @state = state
    end
    
    def recorded_object
      @state.recorded_object
    end
    
    def recorded_data
      @state.recorded_data
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