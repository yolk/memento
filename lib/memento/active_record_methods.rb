module Memento::ActiveRecordMethods
  
  IGNORE_ATTRIBUTES = [:updated_at, :created_at]
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def memento_changes(*action_types)
      include InstanceMethods
      
      self.memento_options = action_types.last.is_a?(Hash) ? action_types.pop : {}
      
      action_types = Memento::Action::Base.action_types if action_types.empty?
      action_types.map!(&:to_s).uniq!
      unless (invalid = action_types - Memento::Action::Base.action_types).empty?
        raise ArgumentError.new("Invalid memento_changes: #{invalid.to_sentence}; allowed are only #{Memento::Action::Base.action_types.to_sentence}")
      end
      
      action_types.each do |action_type|
        callback_exists = send(:"after_#{action_type}_callback_chain").any? do |callback|
          callback.method.to_sym == :"record_#{action_type}"
        end
        send :"after_#{action_type}", :"record_#{action_type}" unless callback_exists
      end
      
      has_many :memento_states, :class_name => "Memento::State", :as => :record
    end
    
    def memento_options
      read_inheritable_attribute(:memento_options) || write_inheritable_attribute(:memento_options,{})
    end
    
    def memento_options=(options)
      options.symbolize_keys!
      options[:ignore] = [options[:ignore]].flatten.map(&:to_sym) if options[:ignore]
      write_inheritable_attribute(:memento_options, memento_options.merge(options))
    end
  end
  
  module InstanceMethods
    
    def attributes_for_memento
      filter_attributes_for_memento(attributes)
    end
    
    def changes_for_memento
      filter_attributes_for_memento(changes)
    end
    
    private
    
    def filter_attributes_for_memento(hash)
      hash.delete_if do |key, value| 
        ignore_attributes_for_memento.include?(key.to_sym)
      end
    end
    
    def ignore_attributes_for_memento
      Memento::ActiveRecordMethods::IGNORE_ATTRIBUTES + (self.class.memento_options[:ignore] || [])
    end
    
    Memento::Action::Base.action_types.each do |action_type|
      define_method :"record_#{action_type}" do
        Memento.instance.add_state(action_type, self)
      end
    end
  end
  
end

ActiveRecord::Base.send(:include, Memento::ActiveRecordMethods) if defined?(ActiveRecord::Base)