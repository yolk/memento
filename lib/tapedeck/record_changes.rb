module Tapedeck::RecordChanges
  
  IGNORE_ATTRIBUTES = [:updated_at, :created_at]
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def record_changes(action_type_types=Tapedeck::Action::Base.action_types)
      include InstanceMethods
      
      action_type_types.each do |action_type|
        callback_exists = send(:"after_#{action_type}_callback_chain").any? do |callback|
          callback.method.to_sym == :"record_#{action_type}"
        end
        send :"after_#{action_type}", :"record_#{action_type}" unless callback_exists
      end
      
      has_many :tapedeck_tracks, :class_name => "Tapedeck::Track", :as => :recorded_object
    end
  end
  
  module InstanceMethods
    
    def attributes_for_recording
      attributes.delete_if{|key, value| Tapedeck::RecordChanges::IGNORE_ATTRIBUTES.include?(key.to_sym) }
    end
    
    def changes_for_recording
      changes.delete_if{|key, value| Tapedeck::RecordChanges::IGNORE_ATTRIBUTES.include?(key.to_sym) }
    end
    
    private
    
    Tapedeck::Action::Base.action_types.each do |action_type|
      define_method :"record_#{action_type}" do
        Tapedeck.instance.add_track(action_type, self)
      end
    end
  end
  
end

ActiveRecord::Base.send(:include, Tapedeck::RecordChanges) if defined?(ActiveRecord::Base)