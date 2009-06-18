class Tapedeck
  module RecordInController
    
    private
    
    def recording
      block_result = nil
      response.headers["X-TapedeckSessionId"] = Tapedeck.instance.recording(current_user) do
        block_result = yield
      end.id
      block_result
    end
  end
end

ActionController::Base.send(:include, Tapedeck::RecordInController) if defined?(ActionController::Base)