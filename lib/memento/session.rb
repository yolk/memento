module Memento
  class Session < ActiveRecord::Base
    self.table_name = "memento_sessions"

    has_many :states, -> { order "id DESC" },
             :class_name => "Memento::State", :dependent => :delete_all
    belongs_to :user

    # attr_accessible nil

    validates_presence_of :user

    def add_state(action_type, record)
      state = Memento::State.build(action_type, record)
      tmp_states << state if state
    end

    def undo
      states.map(&:undo).inject(Memento::ResultArray.new) do |results, result|
        result.state.destroy if result.success?
        results << result
      end
    ensure
      destroy if states.count.zero?
    end

    def undo!
      transaction do
        undo.tap do |results|
          raise Memento::ErrorOnRewind if results.failed?
        end
      end
    end

    def tmp_states
      @tmp_states ||= []
    end

    private

    after_save :store_tmp_states

    def store_tmp_states
      return unless tmp_states.any?
      tmp_states.each do |state|
        self.states << state
        state.save
      end
      @tmp_states = []
    end
  end
end
