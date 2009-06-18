class Memento
  module ActionControllerMethods
    
    private
    
    def recording
      block_result = nil
      response.headers["X-MementoSessionId"] = Memento.instance.recording(current_user) do
        block_result = yield
      end.id
      block_result
    end
  end
end

ActionController::Base.send(:include, Memento::ActionControllerMethods) if defined?(ActionController::Base)