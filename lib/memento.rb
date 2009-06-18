class Memento
  include Singleton
  
  class ErrorOnRewind < StandardError;end
  
  def recording(user)
    start(user)
    yield
    @session
  ensure
    stop
  end
  
  def start(user_or_id)
    user = User.find_by_id(user_or_id)
    @session = user ? Memento::Session.new(:user => user) : nil
  end
  
  def stop
    @session = nil
  end
  
  def add_state(action_type, record)
    return unless save_session
    @session.add_state(action_type, record)
  end
  
  def recording?
    !!(defined?(@session) && @session)
  end
  
  private
  
  def save_session
    recording? && (!@session.changed? || @session.save)
  end
end

require 'memento/result'
require 'memento/action'
require 'memento/record_changes'
require 'memento/record_in_controller'
require 'memento/state'
require 'memento/session'