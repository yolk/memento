require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'spec'

# Initialize time_zones from rails
Time.zone_default = Time.__send__(:get_zone, 'Berlin') || raise("Err")
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tapedeck'

Spec::Runner.configure do |config|
  
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
# catch AR schema statements
$stdout = StringIO.new

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :projects do |t|
      t.column :name, :string
      t.column :closed_at, :datetime
      t.column :notes, :string
      t.references :customer
      t.timestamps
    end
    
    create_table :users do |t|
      t.column :email, :string
      t.column :name, :string
      t.timestamps
    end
    
    create_table :customers do |t|
      t.column :name, :string
      t.timestamps
    end
    
    create_table :tapedeck_sessions do |t|
      t.references :user
      t.timestamps
    end
    
    create_table :tapedeck_tracks do |t|
      t.string :action_type
      t.binary :recorded_data, :limit => 1.megabytes
      t.references :recorded_object, :polymorphic => true
      t.references :session
      t.timestamps
    end
    
  end
end

def setup_data
  @user = User.create(:name => "MyUser")
end
 
def shutdown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
 
class User < ActiveRecord::Base
end

class Customer < ActiveRecord::Base
  has_many :projects
end

class Project < ActiveRecord::Base
  belongs_to :customer
  
  record_changes
end