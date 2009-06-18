class Tapedeck::Session < ActiveRecord::Base
  set_table_name "tapedeck_sessions"
  
  has_many :tracks, :class_name => "Tapedeck::Track", :dependent => :delete_all
  belongs_to :user
  validates_presence_of :user
  
  def add_track(action_type, recorded_object)
    tracks.create(:action_type => action_type.to_s, :recorded_object => recorded_object)
  end
  
  def rewind
    rewinded = tracks.map(&:rewind).inject(Tapedeck::ResultArray.new) do |array, entry|
      array << Tapedeck::Result.new(entry)
    end
    destroy
    rewinded
  end
  
end