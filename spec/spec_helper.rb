require 'active_support'
require 'active_support/time'
require 'active_record'
require 'action_controller'
require 'rspec'

I18n.enforce_available_locales = false

# Initialize time_zones from rails
Time.zone = "Berlin"
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'memento'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
# catch AR schema statements
$stdout = StringIO.new

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :projects do |t|
      t.column :name, :string
      t.column :closed_at, :datetime
      t.column :notes, :text
      t.references :customer
      t.integer :ignore_this
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

    create_table :timestampless_objects do |t|
      t.column :name, :string
    end

    create_table :memento_sessions do |t|
      t.references :user
      t.timestamps
    end

    create_table :memento_states do |t|
      t.string :action_type
      t.binary :record_data, :limit => 16777215
      t.references :record, :polymorphic => true
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
end unless defined?(User)

class Customer < ActiveRecord::Base
  has_many :projects
end unless defined?(Customer)

class Project < ActiveRecord::Base
  belongs_to :customer

  memento_changes :ignore => :ignore_this
end unless defined?(Project)

class TimestamplessObject < ActiveRecord::Base
  memento_changes
end unless defined?(TimestamplessObject)