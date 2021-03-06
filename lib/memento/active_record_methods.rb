require 'active_support/core_ext/class/attribute'

module Memento::ActiveRecordMethods

  IGNORE_ATTRIBUTES = [:updated_at, :created_at]

  def self.included(base)
    base.class_attribute(:memento_options_store, :instance_reader => false, :instance_writer => false)
    base.memento_options_store = {}
    base.extend ClassMethods
  end

  module ClassMethods

    def memento_changes(*action_types)
      if defined?(@memento_initialized) && @memento_initialized
        raise "Memento initialized twice. Use memento_changes only once per model"
      end

      @memento_initialized = true

      include InstanceMethods

      self.memento_options = action_types.last.is_a?(Hash) ? action_types.pop : {}

      action_types = Memento::Action::Base.action_types if action_types.empty?
      action_types.map!(&:to_s).uniq!
      unless (invalid = action_types - Memento::Action::Base.action_types).empty?
        raise ArgumentError.new("Invalid memento_changes: #{invalid.to_sentence}; allowed are only #{Memento::Action::Base.action_types.to_sentence}")
      end

      action_types.each do |action_type|
        send :"after_#{action_type}", :"memento_record_after_#{action_type}"
      end

      has_many :memento_states, :class_name => "Memento::State", :as => :record
    end

    def memento_options
      self.memento_options_store ||= {}
    end

    def memento_options=(options)
      options.symbolize_keys!
      options[:ignore] = [options[:ignore]].flatten.map(&:to_sym) if options[:ignore]
      self.memento_options_store = memento_options_store.merge(options)
    end
  end

  module InstanceMethods

    def attributes_for_memento
      filter_attributes_for_memento(attributes)
    end

    def changes_for_memento
      filter_attributes_for_memento(saved_changes)
    end

    def filter_attributes_for_memento(hash)
      hash.delete_if do |key, value|
        ignore_attributes_for_memento.include?(key.to_sym)
      end
    end
    private :filter_attributes_for_memento

    def ignore_attributes_for_memento
      Memento::ActiveRecordMethods::IGNORE_ATTRIBUTES + (self.class.memento_options[:ignore] || [])
    end
    private :ignore_attributes_for_memento

    Memento::Action::Base.action_types.each do |action_type|
      define_method :"memento_record_after_#{action_type}" do
        Memento.add_state(action_type, self)
      end
      private :"memento_record_after_#{action_type}"
    end
  end

end

ActiveSupport.on_load(:active_record) do
  include Memento::ActiveRecordMethods
end
