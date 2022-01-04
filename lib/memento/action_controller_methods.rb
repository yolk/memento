module Memento
  module ActionControllerMethods

    def memento
      block_result = nil
      memento_session = Memento.watch(current_user) do
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

ActiveSupport.on_load(:action_controller) do
  include Memento::ActionControllerMethods
end
