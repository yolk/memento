require 'active_record'

module Memento

  class ErrorOnRewind < StandardError;end

  class << self

    # For backwards compatibility (was a Singleton)
    def instance
      self
    end

    def watch(user_or_id)
      start(user_or_id)
      yield
      session && !session.new_record? && session.states.any? ? session : false
    ensure
      stop
    end

    def start(user_or_id)
      user = user_or_id.is_a?(User) ? user_or_id : User.where(:id => user_or_id).first
      self.session = user ? Memento::Session.new(:user => user) : nil
    end

    def stop
      session.destroy if session && session.states.count.zero?
      self.session = nil
    end

    def add_state(action_type, record)
      return unless save_session
      session.add_state(action_type, record)
    end

    def active?
      !!session && !ignore?
    end

    def ignore
      Thread.current[:memento_ignore] = true
      yield
    ensure
      Thread.current[:memento_ignore] = false
    end

    def serializer=(serializer)
      @serializer = serializer
    end

    def serializer
      @serializer ||= YAML
    end

    def ignore?
      !!Thread.current[:memento_ignore]
    end

    private

    def session
      Thread.current[:memento_session]
    end

    def session=(session)
      Thread.current[:memento_session] = session
    end

    def save_session
      active? && (!session.changed? || session.save)
    end
  end
end

def Memento(user_or_id, &block)
  Memento.watch(user_or_id, &block)
end

require 'memento/railtie'
require 'memento/result'
require 'memento/action'
require 'memento/active_record_methods'
require 'memento/action_controller_methods'
require 'memento/state'
require 'memento/session'
