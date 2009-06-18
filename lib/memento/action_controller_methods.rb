class Memento
  module ActionControllerMethods
    
    private
    
    def memento
      block_result = nil
      memento_session = Memento.instance.memento(current_user) do
        block_result = yield
      end
      if memento_session && memento_session.id
        response.headers["X-Memento-Session-Id"] = memento_session.id
      end
      block_result
    end
  end
end

ActionController::Base.send(:include, Memento::ActionControllerMethods) if defined?(ActionController::Base)