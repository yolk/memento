class Memento::State < ActiveRecord::Base
  self.table_name = "memento_states"

  belongs_to :session, :class_name => "Memento::Session"
  belongs_to :record, :polymorphic => true

  validates_presence_of :session
  validates_presence_of :record
  validates_presence_of :action_type
  validates_inclusion_of :action_type, :in => Memento::Action::Base.action_types, :allow_blank => true

  before_create :set_record_data

  def self.store(action_type, record)
    self.new(:action_type => action_type.to_s, :record => record) do |state|
      state.save if state.fetch?
    end
  end

  def undo
    Memento::Result.new(action.undo, self)
  end

  def record_data
    @record_data ||= Memento.serializer.load(read_attribute(:record_data))
  end

  def record_data=(data)
    @record_data = nil
    write_attribute(:record_data, data.is_a?(String) ? data : Memento.serializer.dump(data))
  end

  def fetch?
    action.fetch?
  end

  private

  def set_record_data
    self.record_data = action.fetch
  end

  def action
    "memento/action/#{action_type}".classify.constantize.new(self)
  end

end