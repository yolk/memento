class Tapedeck::Session < ActiveRecord::Base
  set_table_name "tapedeck_sessions"
  
  has_many :tracks, :class_name => "Tapedeck::Track", :dependent => :delete_all
  belongs_to :user
  validates_presence_of :user
  
  def add_track(action_type, recorded_object)
    tracks.create(:action_type => action_type.to_s, :recorded_object => recorded_object)
  end
  
  def rewind
    tracks.map(&:rewind).inject(Tapedeck::ResultArray.new) do |results, result|
      result.track.destroy if result.success?
      results << result
    end
  ensure
    destroy if tracks.count.zero?
  end
  
end