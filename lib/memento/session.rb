class Memento::Session < ActiveRecord::Base
  set_table_name "memento_sessions"
  
  has_many :tracks, :class_name => "Memento::Track", :dependent => :delete_all
  belongs_to :user
  validates_presence_of :user
  
  def add_track(action_type, recorded_object)
    tracks.create(:action_type => action_type.to_s, :recorded_object => recorded_object)
  end
  
  def rewind
    tracks.map(&:rewind).inject(Memento::ResultArray.new) do |results, result|
      result.track.destroy if result.success?
      results << result
    end
  ensure
    destroy if tracks.count.zero?
  end
  
  def rewind!
    transaction do
      returning(rewind) do |results|
        raise Memento::ErrorOnRewind if results.failed?
      end
    end
  end
  
end