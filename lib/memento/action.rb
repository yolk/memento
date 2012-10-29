require 'active_support/core_ext/class/attribute'

module Memento::Action
  class Base
    def initialize(state)
      @state = state
    end

    attr_reader :state
    class_attribute :action_types, :instance_reader => false, :instance_writer => false
    self.action_types = []

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
      self.action_types << child.name.demodulize.underscore
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