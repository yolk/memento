module Memento
  module ActionControllerMethods

    def memento
      block_result = nil
      memento_session = Memento(current_user) do
        block_result = yield
      end
      if memento_session
        response.headers["X-Memento-Session-Id"] = memento_session.id.to_s
      end
      block_result
    end
    private :memento
  end
end

ActionController::Base.send(:include, Memento::ActionControllerMethods) if defined?(ActionController::Base)