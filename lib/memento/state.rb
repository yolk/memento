class Memento::State < ActiveRecord::Base
  set_table_name "memento_states"
  
  belongs_to :session, :class_name => "Memento::Session"
  belongs_to :recorded_object, :polymorphic => true
  
  validates_presence_of :session
  validates_presence_of :recorded_object
  validates_presence_of :action_type
  validates_inclusion_of :action_type, :in => Memento::Action::Base.action_types, :allow_blank => true
  
  before_create :set_recorded_data
  
  def rewind
    Memento::Result.new(action.rewind, self)
  end
  
  def recorded_data
    @recorded_data ||= Marshal.load(super)
  end
  
  def recorded_data=(data)
    @recorded_data = nil
    super(Marshal.dump(data))
  end
  
  def new_object
    object = recorded_object_type.constantize.new
    yield(object) if block_given?
    object
  end
  
  def rebuild_object(*skip)
    skip = skip ? skip.map(&:to_sym) : []
    new_object do |object|
      recorded_data.each do |attribute, value|
        object.send(:"#{attribute}=", value) unless skip.include?(attribute.to_sym)
      end
      yield(object) if block_given?
    end
  end
  
  def later_states_on_recorded_object_for(action_type_param)
    Memento::State.all(:conditions => [
      "recorded_object_id = ? AND recorded_object_type = ? AND " + 
      "action_type = ? AND created_at >= ? AND id != ? ", 
      recorded_object_id, recorded_object_type, action_type_param.to_s, created_at, id
    ])
  end
  
  private
  
  def set_recorded_data
    self.recorded_data = action.record
  end
  
  def action
    "memento/action/#{action_type}".classify.constantize.new(self)
  end
  
end