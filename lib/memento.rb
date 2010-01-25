class Memento
  include Singleton
  
  class ErrorOnRewind < StandardError;end
  
  def memento(user)
    start(user)
    yield
    !@session.states.count.zero? && @session rescue false
  ensure
    stop
  end
  
  def start(user_or_id)
    user = User.find_by_id(user_or_id)
    @session = user ? Memento::Session.new(:user => user) : nil
  end
  
  def stop
    @session.destroy if @session && @session.states.count.zero?
    @session = nil
  end
  
  def add_state(action_type, record)
    return unless save_session
    @session.add_state(action_type, record)
  end
  
  def active?
    !!(defined?(@session) && @session) && !ignore?
  end
  
  def ignore
    @ignore = true
    yield
  ensure
    @ignore = false
  end
  
  cattr_accessor :serializer
  self.serializer = YAML
  
  private
  
  def ignore?
    defined?(@ignore) && @ignore
  end
  
  def save_session
    active? && (!@session.changed? || @session.save)
  end
end

require 'memento/result'
require 'memento/action'
require 'memento/active_record_methods'
require 'memento/action_controller_methods'
require 'memento/state'
require 'memento/session'